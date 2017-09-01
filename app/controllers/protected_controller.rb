class ProtectedController < ApplicationController

    before_action :authorize

    def authorize

        auth = request.env["HTTP_X_AUTH"]

        if !auth
            render_error 403, :auth_invalid, "Provide auth header X-Auth"
            return
        end

        id, token = auth.split("-")

        session = UserSession.find(id)

        if !session
            render_error 403, :auth_invalid, "Invalid token provided"
            return
        end

        if !session.authenticate(token)
            render_error 403, :auth_invalid, "Invalid token provided"
            return        
        end
        
        if !session.user.active
            render_error 403, :missing_permissions, "The user has been deactivated"
            return        
        end

        @user = session.user
    end

end