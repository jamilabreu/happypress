class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.text :title
      t.text :url, index: true, unique: true

      t.timestamps
    end
  end
end
