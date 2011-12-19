class CreateAvatars < ActiveRecord::Migration
  def self.up
    create_table :avatars do |t|
      t.column :user_id, :integer, { :null => false }
      t.column :content_type, :string
      t.column :filename, :string
      t.column :size, :integer

      # acts_as_list
      t.column :position, :integer

      # used with thumbnails, always required
      t.column :parent_id,  :integer
      t.column :thumbnail, :string

      # required for images only
      t.column :width, :integer
      t.column :height, :integer
    end

    add_index :avatars, :user_id
    add_index :avatars, :parent_id
  end

  def self.down
    drop_table :avatars
  end
end
