class AddTimestamps < ActiveRecord::Migration
  def change
    change_table(:newsletters) { |t| t.timestamps }
    change_table(:hrefs) { |t| t.timestamps }
  end
end
