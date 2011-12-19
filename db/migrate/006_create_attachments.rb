class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.column :entry_id, :integer, { :null => false }
      t.column :content_type, :string
      t.column :filename, :string, { :null => false }
      t.column :size, :integer, { :null => false }

      # тип аттачмента
      t.column :type, :string

      # метаданные
      t.column :metadata, :string

      # only for thumbnails
      t.column :parent_id,  :integer, { :null => true }
      t.column :thumbnail, :string

      # only for images (optional)
      t.column :width, :integer
      t.column :height, :integer
    end

    add_index :attachments, :entry_id
    add_index :attachments, :parent_id
  end

  def self.down
    drop_table :attachments
  end
end
