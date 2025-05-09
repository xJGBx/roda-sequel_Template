class Router
  hash_branch('admin') do |r|
    r.is 'route' do
      if admin_authenticated?
        # Example Admin Actions
        {
          message: 'Welcome, Admin! Here are your admin tools.',
          actions: ['Manage Users', 'View Analytics', 'Modify Settings']
        }
      else
        response.status = 401
        { error: 'Unauthorized access' }
      end
    end
  end

  def generate_admin_token
    payload = { admin: true, exp: Time.now.to_i + (60 * 60) } # 1-hour expiration
    JWT.encode(payload, ENV['SECRET_KEY'], 'HS256')
  end

  def verify_admin_password(password)
    BCrypt::Password.new(ENV['ADMIN_PASSWORD_HASH']) == password
  end

  def admin_authenticated?
    token = request.env['HTTP_AUTHORIZATION']&.split(' ')&.last
    return false unless token

    begin
      payload = JWT.decode(token, ENV['SECRET_KEY'], true, { algorithm: 'HS256' })[0]
      payload['admin'] == true
    rescue JWT::DecodeError
      false
    end
  end
end
