class CreateHelps < ActiveRecord::Migration
  def self.up
    create_table :helps do |t|
      t.column :path, :string, { :null => false }
      t.column :body, :text
      t.column :impressions, :integer, { :null => false, :default => 0 }
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
    end
  end

  def self.down
    drop_table :helps
  end
end
