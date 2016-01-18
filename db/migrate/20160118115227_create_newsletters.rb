class CreateNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.string :title
      t.string :email
    end

    add_index :newsletters, :emai]
  end
end
