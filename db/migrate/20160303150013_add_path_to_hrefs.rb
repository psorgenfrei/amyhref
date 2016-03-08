class AddPathToHrefs < ActiveRecord::Migration
  def change
    add_column :hrefs, :path, :text
  end
end
