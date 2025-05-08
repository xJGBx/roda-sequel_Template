class Router
    hash_branch("users") do |r|
      r.is "register" do
        r.post do
          user_params = r.params.slice("username", "email", "password")
          user = User.new(username: user_params["username"], email: user_params["email"])
          user.password = user_params["password"]
  
          if user.valid?
            user.save
            user = User.find(email: r.params["email"])
            token = User.create_jwt(user.id)
            { message: "User registered and logged in successfully", token: token }
          else
            response.status = 422
            { error: "Registration failed", details: user.errors.full_messages }
          end
        end
      end
  
      r.is "login" do
        r.post do
          user = User.find(email: r.params["email"])
      
          if user && user.authenticate(r.params["password"])
            token = User.create_jwt(user.id)
            response.status = 200
            { message: "Login successful", token: token }
          else
            response.status = 401
            { error: "Invalid email or password" }
          end
        end
      end    
  
      r.is "delete_account" do
        r.post do
          token = r.headers["Authorization"]&.split(" ")&.last
          user_id = User.decode_jwt(token)
  
          if user_id
            user = User[user_id]
            user.destroy
            { message: "Account deleted successfully" }
          else
            response.status = 401
            { error: "Invalid token" }
          end
        end
      end
  
      r.is "user_details" do
        r.get do
          user = authenticated_user  # Assumes this raises an error if the user is unauthenticated.
      
          if user
            response.status = 200
            { user_id: user.id, username: user.username, email: user.email }
          else
            response.status = 401
            { error: "Unauthorized access" }
          end
        end
      end

      r.is "forgot_password" do
        r.post do
          email = r.params['email']
          user = User.first(email: email)
          
          if user
            reset_code = SecureRandom.hex(2)
            expiration = Time.now + (24 * 60 * 60) # 24 hours from now
            
            user.update(reset_code: reset_code, reset_code_expires_at: expiration)
            
            # Send the reset link to the user's email (pseudo-code)
            send_email(user.email, "Password Reset", "Click here to reset your password: /reset_password?code=#{reset_code}")
          
          { success: "If this email is registered, a password reset link has been sent." }
          else
            response.status = 404
            { error: "User not found" }
          end  
        end
      end
  
      r.is "reset_password" do
        r.get do
          code = r.params['code']
          user = User.first(reset_code: code)
          
          if user && user.reset_code_expires_at > Time.now
            # Render a form to reset the password
            #render_reset_password_form(user)
          else
            { error: "Invalid or expired reset code." }
          end  
        end
  
        r.post do
          code = r.params['code']
          new_password = r.params['password']
          user = User.first(reset_code: code)
          
          if user && user.reset_code_expires_at > Time.now
            # Update the user's password and clear the reset code
            user.update(password: new_password, reset_code: nil, reset_code_expires_at: nil)
            { success: "Password successfully reset." }
          else
            { error: "Invalid or expired reset code." }
          end
        end
      end
    end
  end
end