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

        starts_at = b.starts_at
        ends_at = b.ends_at

        # Run check and create in transation to avoid timing issues
        Booking.transaction do

            if b.booking_conflict
                render_error 403, :double_booked, "The time provided conflicts with another booking"
                return
            end

            begin 
                b.save!
            rescue ActiveRecord::RecordInvalid => e
                render_error 400, :invalid_request, e.to_s
                return
            end

        end
    
        render json: {success: true}
    end

    def index
        models = Booking.all
        render json: models
    end

end