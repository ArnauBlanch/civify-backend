# Handles controller exceptions
module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { message: e.message }, status: :bad_request
    end
  end
end