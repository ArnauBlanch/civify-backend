# Handles controller exceptions
module ExceptionHandler
  extend ActiveSupport::Concern
  include RenderUtils

  included do
    rescue_from ActiveRecord::RecordInvalid do |e|
      render_debug e.record.errors.full_messages[0]
    end
    rescue_from ActiveRecord::RecordNotUnique do
      render_debug 'Already exists'
    end
  end

  def render_debug(message)
    puts "RESCUED: #{message}" if DEBUG
    render_from(message: message, status: :bad_request)
  end

end