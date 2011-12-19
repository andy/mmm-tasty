class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.column :user_id, :integer, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
      t.column :message, :text, :null => false
      t.column :is_public, :boolean, :null => false, :default => 0
      t.column :is_moderated, :boolean, :null => false, :default => 0
    end

    add_index :feedbacks, [:user_id], :unique => true
    add_index :feedbacks, [:is_public, :created_at]
    add_index :feedbacks, [:is_moderated, :created_at]
  end

  def self.down
    drop_table :feedbacks
  end
end
