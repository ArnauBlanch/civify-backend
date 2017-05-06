module Response
  def json_response(message, status = :ok)
    render json: message, status: status
  end
end