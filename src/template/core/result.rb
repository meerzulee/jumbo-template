# app/core/result.rb
#
# Immutable result object using Ruby 3.2+ Data.
#
#   result = Result.success(order: order, total: 69.97)
#   result.success?  # => true
#   result.order     # => #<Order ...>
#   result.total     # => 69.97
#   result[:order]   # => #<Order ...>  (hash-style access too)
#
#   result = Result.failure("Payment declined", order: order)
#   result.failure?  # => true
#   result.error     # => "Payment declined"
#   result.order     # => #<Order ...>  (still accessible for cleanup)
#
#   # Immutable — this raises FrozenError:
#   result.order = something_else
#
class Result
  attr_reader :error

  def initialize(success:, data: ResultData.empty, error: nil)
    @success = success
    @data    = data
    @error   = error
    freeze
  end

  def success? = @success
  def failure? = !@success

  # ── Constructors ─────────────────────────────────────────

  def self.success(data = {})
    new(success: true, data: ResultData.build(data))
  end

  def self.failure(error, data = {})
    new(success: false, error:, data: ResultData.build(data))
  end

  # ── Data Access ──────────────────────────────────────────

  # result.order, result.total, etc.
  def method_missing(name, *args)
    @data.respond_to?(name) ? @data.send(name, *args) : super
  end

  def respond_to_missing?(name, include_private = false)
    @data.respond_to?(name) || super
  end

  # result[:order]
  def [](key) = @data[key]

  # For merging nested operation results back into ctx
  def to_h = @data.to_h

  def inspect
    status = @success ? "SUCCESS" : "FAILURE"
    "#<Result #{status} #{@data.to_h.keys.join(', ')}#{@error ? " error=#{@error.inspect}" : ""}>"
  end
end

# ── ResultData ─────────────────────────────────────────────
#
# Thin wrapper that dynamically defines a Data class per
# unique set of keys, then caches it.
#
# Why not Data.define directly in Result?
#   Data.define needs members at define-time, but operations
#   pass arbitrary keys. So we build and cache a Data class
#   for each unique key signature.
#
#   First call with {order:, total:} → defines Data.define(:order, :total)
#   Second call with same keys       → reuses cached class
#
class ResultData
  @cache = {}

  class << self
    def build(hash)
      return empty if hash.nil? || hash.empty?

      hash = hash.to_h if hash.respond_to?(:to_h) && !hash.is_a?(Hash)
      keys = hash.keys.sort

      data_class = @cache[keys] ||= Data.define(*keys)
      data_class.new(**hash)
    end

    def empty
      @empty ||= EmptyData.new
    end
  end

  # Null object for empty results — responds to nothing, returns nil
  class EmptyData
    def [](*)              = nil
    def to_h               = {}
    def respond_to_missing?(*) = false
    def method_missing(*)  = nil # rubocop:disable Style/MissingRespondToMissing
  end
end
