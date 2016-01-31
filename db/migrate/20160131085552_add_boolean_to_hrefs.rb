class AddBooleanToHrefs < ActiveRecord::Migration
  def change
    add_column :hrefs, :good, :boolean, :default => false
  end
end
