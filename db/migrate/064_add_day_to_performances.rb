class AddDayToPerformances < ActiveRecord::Migration
  def self.up
    add_column :performances, :day, :date, :null => false
    remove_column :performances, :function
    add_index :performances, [:controller, :action, :day], :unique => true
    remove_index :performances, [:controller, :action, :function]
  end

  def self.down
    remove_column :performances, :day
    add_column :performances, :function, :string
  end
end
