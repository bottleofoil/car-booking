class Booking < ApplicationRecord  
    belongs_to :user
    belongs_to :car   

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
end