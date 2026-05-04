class ApplicationQuery
  attr_reader :scope

  def initialize(scope = nil)
    @scope = scope || default_scope
  end

  private

  def default_scope
    raise NotImplementedError,
          "#{self.class} must implement #default_scope or be initialized with an explicit scope"
  end
end
