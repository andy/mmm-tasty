class CreateSocialAds < ActiveRecord::Migration
  def self.up
    create_table :social_ads do |t|
      t.column :user_id, :integer, { :null => false }
      t.column :entry_id, :integer, { :null => false }
      t.column :annotation, :string, { :null => false }
      t.column :created_at, :timestamp, { :null => false }
      t.column :impressions, :integer, { :null => false, :default => 0 }
      t.column :clicks, :integer, { :null => false, :default => 0 }
    end

    add_index :social_ads, [:user_id, :entry_id], :unique => true
    add_index :social_ads, [:created_at, :user_id]
  end

  def self.down
    drop_table :social_ads
  end
end
