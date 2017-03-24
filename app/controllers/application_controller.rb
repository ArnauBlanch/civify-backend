require 'concerns/exception_handler'

# ApplicationController that inherits from ActionController::API
class ApplicationController < ActionController::API
  include ExceptionHandler
end
