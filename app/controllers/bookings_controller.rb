class BookingsController < ApplicationController

    def create
        b = Booking.new
        b.user_id = User.first.id
        required = [:car_id, :starts_at, :ends_at]
        required.each do |p|
            if !params[p]
                render_error 400, :invalid_request, "Missing required field: " + p.to_s
                return
            end
            b[p] = params[p]
        end
        begin 
            b.save!
        rescue ActiveRecord::RecordInvalid => e
            render_error 400, :invalid_request, e.to_s
            return
        end
        render json: {success: true}
    end

    def index
        models = Booking.all
        render json: models
    end

end