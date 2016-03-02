class AddRatingToHrefs < ActiveRecord::Migration
  def change
    add_column :hrefs, :rating, :float
  end
end
