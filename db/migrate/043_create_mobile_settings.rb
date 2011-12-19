class CreateMobileSettings < ActiveRecord::Migration
  def self.up
    create_table :mobile_settings do |t|
      t.column :user_id, :integer, { :null => false }
      t.column :keyword, :string, { :null => false }

      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    add_index :mobile_settings, [:user_id], :unique => true
    add_index :mobile_settings, [:keyword], :unique => true
  end

  def self.down
    drop_table :mobile_settings
  end
end

