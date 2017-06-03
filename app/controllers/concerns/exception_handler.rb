# Handles controller exceptions
module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { message: e.record.errors.full_messages[0] }, status: :bad_request
    end
    rescue_from ActiveRecord::RecordNotUnique do
      render json: { message: 'Already exists' }, status: :bad_request
    end
  end

end