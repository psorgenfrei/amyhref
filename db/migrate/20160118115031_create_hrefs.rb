class CreateHrefs < ActiveRecord::Migration
  def change
    create_table :hrefs do |t|
      t.text :url
      t.string :domain
      t.belongs_to :newsletter
    end

    add_index :hrefs, :domain
    add_index :hrefs, :newsletter_id
  end
end
