class AddLastProcessedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_processed, :datetime
  end
end
