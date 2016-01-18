class CreateNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.string :title
      t.string :email
      t.timestamps
    end

    add_index :newsletters, :email
    add_index :newsletters, :created_at
  end
end
