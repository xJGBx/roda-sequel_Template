# models/user.rb
class User < Sequel::Model
  def password=(new_password)
    self.password_digest = BCrypt::Password.create(new_password)
  end

  def authenticate(password)
    BCrypt::Password.new(self.password_digest) == password
  end

  def self.create_jwt(user_id)
    payload = { user_id: user_id }
    secret_key = ENV["SECRET_KEY"]
    JWT.encode(payload, secret_key, "HS256")
  end

  def self.decode_jwt(token)
    secret_key = ENV["SECRET_KEY"]
    decoded_token = JWT.decode(token, secret_key, true, { algorithm: "HS256" })
    decoded_token.first["user_id"]
  rescue JWT::DecodeError
    nil
  end

  def validate
    super
    validates_presence [:username, :email, :password_digest]
    validates_unique [:username, :email]
  end
end
