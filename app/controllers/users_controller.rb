class UsersController < ApplicationController

    def create
        user = User.new
        user.email = params[:email]
        user.password = params[:password]

        begin 
            user.save!
        rescue ActiveRecord::RecordInvalid => e
            render_error 400, :invalid_request, e.to_s
            return
        end        

        render json: {}
    end

end