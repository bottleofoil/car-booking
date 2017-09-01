class AuthController < ApplicationController

    def create

        user = User.find_by_email(params[:email])
        if !user
            render_error 403, :invalid_user, "No user found with provided email"
            return
        end

        if !user.active
            render_error 403, :user_deactivated, "Provided user is deactivated"
            return
        end          

        if !user.authenticate(params[:password])
            render_error 403, :invalid_password, "Invalid password"
            return
        end

        password = SecureRandom.hex(16)

        session = UserSession.new
        session.user_id = user.id
        session.password = password
        session.save!
        
        render json: {token: session.id.to_s + "-" + password}
    end

end