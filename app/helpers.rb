module Helpers
  def current_user
    token = request.headers["Authorization"]&.split(" ")&.last
    user_id = User.decode_jwt(token)
    user_id ? User[user_id] : nil
  end

  def authenticate!
    response.status = 401 and { error: "Unauthorized" } unless current_user
  end

  def authenticated_user
    user = current_user
    authenticate! if user.nil?
    user
  end

  def admin_authenticated?
    token = request.env["HTTP_AUTHORIZATION"]&.split(" ")&.last
    return false unless token

    begin
      payload = JWT.decode(token, ENV["SECRET_KEY"], true, { algorithm: 'HS256' })[0]
      payload["admin"] == true
    rescue JWT::DecodeError
      false
    end
  end

  def generate_admin_token
    payload = { admin: true, exp: Time.now.to_i + (60 * 60) } # 1-hour expiration
    JWT.encode(payload, ENV["SECRET_KEY"], 'HS256')
  end

  def verify_admin_password(password)
    BCrypt::Password.new(ENV["ADMIN_PASSWORD_HASH"]) == password
  end
end
