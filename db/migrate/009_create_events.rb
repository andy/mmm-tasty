class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.column :current_user_id, :integer
      t.column :current_site_id, :integer
      t.column :message, :text, { :null => false }
      t.column :remote_ip, :string, :limit => 16
      t.column :details, :text
      t.column :created_at, :timestamp
    end
  end

  def self.down
    drop_table :events
  end
end
