class User < ApplicationRecord  
    has_secure_password
    has_many :bookings  

    validates :email, presence: true
end