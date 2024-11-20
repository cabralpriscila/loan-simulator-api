class ServiceResult
  attr_reader :success, :data, :error

  def initialize(success:, data: nil, error: nil)
    @success = success
    @data = data
    @error = error
  end

  def self.success(data)
    new(success: true, data: data)
  end

  def self.failure(error)
    new(success: false, error: error)
  end

  def success?
    @success
  end
end
