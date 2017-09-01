class Booking < ApplicationRecord  
    belongs_to :user
    belongs_to :car   

    enum status: [:created, :started, :completed]

    def booking_conflict
        Booking.where("
            ((starts_at <= ? AND ends_at >= ?) OR
            (starts_at >= ? AND ends_at <= ?) OR 
            (starts_at <= ? AND ends_at >= ?)) 
            AND car_id = ?
        ",
            starts_at, starts_at,
            starts_at, ends_at,
            ends_at, ends_at,
            car_id).exists?        
    end 

    def start
        if !created?
            return :not_created
        end

        start_buffer = 15 * 60
        now = Time.now
        if now < starts_at - start_buffer
            return :too_early
        end
        if now > starts_at + start_buffer
            return :too_late
        end       
        started!
        return nil
    end

    def end 
        if !started?
            return :not_started
        end
        completed!
        return nil
    end

end