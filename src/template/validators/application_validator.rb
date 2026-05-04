class ApplicationValidator
  attr_reader :errors

  def initialize(params = {})
    @params = params
    @errors = []
  end

  def valid?
    @errors.clear
    validate
    @errors.empty?
  end

  def invalid? = !valid?

  private

  attr_reader :params

  def validate
    raise NotImplementedError, "#{self.class} must implement #validate"
  end
end
