class CreateUsersCarsAndBookings < ActiveRecord::Migration[5.1]
  def change
    
    create_table :users do |t|
      t.timestamps
    end

    create_table :cars do |t|
      t.timestamps
    end

    create_table :bookings do |t|
      t.column :starts_at, :timestamp, index: true
      t.column :ends_at, :timestamp, index: true 

      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :car, index: true, foreign_key: true
      
      t.timestamps
    end

  end
end
