class AddUserAuth < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :email, :string
    add_index :users, :email, {unique: true}
    add_column :users, :password_digest, :string
    
    create_table :user_sessions do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string "password_digest"
      t.timestamps
    end

  end
end
