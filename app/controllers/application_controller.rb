class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler

  before_action :authorized

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end

  def decoded_token
    return unless auth_header

    # header: { 'Authorization': 'Bearer <token>' }
    token = auth_header.split(' ')[1]
    begin
      JsonWebToken.decode(token)
    rescue JWT::DecodeError
      nil
    end
  end

  def logged_in_user
    return if decoded_token.blank?

    user_id = decoded_token[0]['user_id']
    @logged_in_user = User.find_by(id: user_id)
  end

  def logged_in?
    !!logged_in_user
  end

  def authorized
    render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
  end

  def authorize_user
    return if current_user&.admin?

    render json: { message: 'Only admin can perform this task' }, status: :unauthorized
  end

  def current_user
    @current_user ||= @logged_in_user
  end
end
