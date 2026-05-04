class ApplicationGateway
  private

  def success(**data)
    Result.success(**data)
  end

  def failure(error, **data)
    Result.failure(error, **data)
  end
end
