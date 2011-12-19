class CreatePerformances < ActiveRecord::Migration
  def self.up
    create_table :performances do |t|
      t.column :controller, :string, :null => false
      t.column :action, :string, :null => false
      t.column :function, :string
      t.column :calls, :integer, :null => false, :default => 0
      t.column :seconds, :float, :null => false, :default => 0
    end

    add_index :performances, [:controller, :action, :function], :unique => true
  end

  def self.down
    drop_table :performances
  end
end
