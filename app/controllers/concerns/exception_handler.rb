# Handles controller exceptions
module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { message: "Doesn't exists record" }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { message: e.message }, status: :bad_request
    end

    rescue_from ActiveRecord::StatementInvalid do |e|
      render json: { message: 'Invalid Statement!!!' }, status: :bad_request
    end
  end
end