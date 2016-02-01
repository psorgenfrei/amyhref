class AddMoreBooleans < ActiveRecord::Migration
  def change
    add_column :hrefs, :good_host, :boolean, :default => false
    add_column :hrefs, :good_path, :boolean, :default => false
  end
end
