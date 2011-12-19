class CreateTlogDesignSettings < ActiveRecord::Migration
  def self.up
    create_table :tlog_design_settings do |t|
      t.column :user_id, :integer
      t.column :theme, :string
      t.column :background_url, :string
      t.column :date_style, :string
      t.column :user_css, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    add_index :tlog_design_settings, [:user_id], :unique => true
  end

  def self.down
    drop_table :tlog_design_settings
  end
end
