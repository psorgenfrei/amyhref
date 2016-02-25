class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.integer :user_id
      t.string :email
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_at
      t.timestamps
    end
  end
end
