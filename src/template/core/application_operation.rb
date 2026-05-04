# app/core/application_operation.rb
#
# Plain Ruby operation base class with Trailblazer-style DSL.
# Zero dependencies. Copy into any Rails app.
#
# Features:
#   step :method             → runs on success track (false/nil = failure)
#   fail_step :method        → runs only on failure track
#   rescue_from:             → catches exceptions, routes to fail track
#   Nested(OtherOperation)   → runs another operation as a step
#   .call(**kwargs)          → normal run, returns Result
#   .wtf?(**kwargs)          → debug run with colored trace output
#
# ── How Failure Detection Works ──────────────────────────────────
#
#   A step is considered FAILED when any of these happen:
#
#   1. Returns `false` or `nil`
#      def validate_items
#        ctx[:items].any?    # returns false if empty → step fails
#      end
#
#   2. Calls `fail!("message")`
#      def validate_customer
#        fail!("Customer suspended") if ctx[:customer].suspended?
#      end
#      # fail! pushes message to @errors, sets @failed = true, returns false
#
#   3. Raises an exception WITH `rescue_from:` declared
#      step :charge_gateway, rescue_from: [RuntimeError, Timeout::Error]
#
#      def charge_gateway
#        raise Timeout::Error, "gateway timed out"  # caught → fail track
#      end
#
#   4. Raises an exception WITHOUT `rescue_from:` → BUBBLES UP (uncaught)
#      This is intentional. Unexpected errors should crash loudly.
#
#   5. Nested operation returns Result.failure → treated as step failure
#
#   Once ANY step fails:
#     - Remaining `step` entries are SKIPPED
#     - `fail_step` entries START running
#     - Transaction is rolled back
#
class ApplicationOperation
  StepFailure = Class.new(StandardError)

  class << self
    def inherited(subclass)
      subclass.instance_variable_set(:@steps, [])
    end

    # ── DSL ────────────────────────────────────────────────

    def step(method_or_nested, rescue_from: nil)
      @steps << { type: :step, target: method_or_nested, rescue_from: }
    end

    def fail_step(method_name)
      @steps << { type: :fail, target: method_name, rescue_from: nil }
    end

    def steps = @steps || []

    # ── Entry Points ───────────────────────────────────────

    def call(**kwargs)
      new(**kwargs).call
    end

    def wtf?(**kwargs)
      new(**kwargs).call(trace: true)
    end

    # ── Nested Helper ──────────────────────────────────────
    # Usage: step Nested(Inventory::Reserve)

    def Nested(operation_class) # rubocop:disable Naming/MethodName
      { nested: operation_class }
    end
  end

  # ── Instance ───────────────────────────────────────────────

  def initialize(**kwargs)
    @ctx     = kwargs.dup
    @errors  = []
    @failed  = false
    @trace   = []
    @tracing = false
  end

  def call(trace: false)
    @tracing = trace

    ActiveRecord::Base.transaction do
      self.class.steps.each { |s| execute_step(s) }
      raise ActiveRecord::Rollback if @failed
    end

    result = if @failed
               Result.failure(@errors.join(", "), @ctx)
             else
               Result.success(@ctx)
             end

    print_trace if @tracing
    result
  end

  private

  # ── Step Execution Engine ──────────────────────────────────

  def execute_step(step_def)
    case step_def[:type]
    when :step
      return if @failed

      if step_def[:target].is_a?(Hash) && step_def[:target][:nested]
        execute_nested(step_def)
      else
        execute_regular(step_def)
      end
    when :fail
      return unless @failed
      execute_fail_step(step_def)
    end
  end

  def execute_regular(step_def)
    method_name = step_def[:target]
    started_at  = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    result = if step_def[:rescue_from]
               begin
                 send(method_name)
               rescue *Array(step_def[:rescue_from]) => e
                 @errors << e.message
                 false
               end
             else
               send(method_name)
             end

    duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at

    if result == false || result.nil?
      @failed = true
      record_trace(method_name, :fail, duration)
    else
      record_trace(method_name, :pass, duration)
    end
  end

  def execute_nested(step_def)
    klass      = step_def[:target][:nested]
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    nested_result = klass.call(**@ctx)

    duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at

    if nested_result.success?
      # Merge nested context back into ours
      @ctx.merge!(nested_result.to_h)
      record_trace("Nested(#{klass})", :pass, duration)
    else
      @errors << nested_result.error
      @failed = true
      record_trace("Nested(#{klass})", :fail, duration)
    end
  end

  def execute_fail_step(step_def)
    method_name = step_def[:target]
    started_at  = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    send(method_name)

    duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
    record_trace(method_name, :fail_handler, duration)
  end

  # ── Context Helpers ────────────────────────────────────────

  def ctx       = @ctx
  def [](key)   = @ctx[key]
  def []=(k, v) = @ctx[k] = v

  def fail!(message)
    @errors << message
    @failed = true
    false
  end

  # ── Trace / wtf? ──────────────────────────────────────────

  def record_trace(name, status, duration)
    @trace << { step: name, status:, duration: }
  end

  def print_trace
    op_name = self.class.name
    w = 58

    puts ""
    puts colorize("╔#{'═' * w}╗", :white)
    puts colorize("║ #{op_name.to_s.ljust(w - 2)} ║", :white)
    puts colorize("╠#{'═' * w}╣", :white)

    @trace.each do |t|
      icon, color = case t[:status]
                    when :pass         then ["✔ ", :green]
                    when :fail         then ["✘ ", :red]
                    when :fail_handler then ["⚡", :yellow]
                    end

      ms   = format("%.2fms", t[:duration] * 1000)
      line = " #{icon} #{t[:step].to_s.ljust(w - 16)} #{ms.rjust(10)}"
      puts colorize("║#{line} ║", color)
    end

    puts colorize("╠#{'═' * w}╣", :white)

    if @failed
      puts colorize("║ ✘ Result: FAILURE#{' ' * (w - 19)}║", :red)
      @errors.each do |err|
        truncated = err.length > (w - 6) ? "#{err[0..(w - 9)]}..." : err
        puts colorize("║   → #{truncated.ljust(w - 6)}║", :red)
      end
    else
      puts colorize("║ ✔ Result: SUCCESS#{' ' * (w - 19)}║", :green)
    end

    puts colorize("╚#{'═' * w}╝", :white)
    puts ""
  end

  COLORS = { red: 31, green: 32, yellow: 33, white: 37 }.freeze

  def colorize(text, color)
    "\e[#{COLORS[color]}m#{text}\e[0m"
  end
end
