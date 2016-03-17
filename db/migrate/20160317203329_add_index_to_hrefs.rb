class AddIndexToHrefs < ActiveRecord::Migration
  def change
    add_index :hrefs, [:user_id, :good]
  end
end
