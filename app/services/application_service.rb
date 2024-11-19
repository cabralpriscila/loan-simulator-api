module ApplicationService
  extend ActiveSupport::Concern

  class_methods do
    def call(*args, **kwargs)
      new(*args, **kwargs).call
    end
  end

  private

  def success(data = {})
    ServiceResult.new(
      success: true,
      data: data,
      error: nil
    )
  end

  def failure(error)
    ServiceResult.new(
      success: false,
      data: nil,
      error: error
    )
  end
end
