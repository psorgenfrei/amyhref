class AddUserIdToHrefs < ActiveRecord::Migration
  def change
    add_column :hrefs, :user_id, :integer, :index => true
  end
end
