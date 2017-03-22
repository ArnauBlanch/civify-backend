require 'concerns/response'
require 'concerns/exception_handler'

# ApplicationController that inherits from ActionController::API
class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
end
