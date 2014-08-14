class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
    	t.integer :entry_id, index: true, unique: true
    	t.text :url
    	t.text :body
      t.references :conversation, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
