class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      # какому сайту принадлежит
      t.column :user_id, :integer, { :null => false }

			# основные данные для записи
      t.column :data_part_1, :text, { :null => true }
      t.column :data_part_2, :text, { :null => true }
      t.column :data_part_3, :text, { :null => true }

			# тип записи (rails single table inheritance)
			t.column :type, :string, { :null => false }

			# заблокирована ли запись?
			t.column :is_disabled, :boolean, { :default => false, :null => false }

			# всякая рабочая фигня
			t.column :created_at, :timestamp, { :null => false }
			t.column :modified_at, :timestamp
    end

    add_index :entries, [:user_id, :created_at, :type]
  end

  def self.down
    drop_table :entries
  end
end
