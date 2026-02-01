class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :github_id
      t.string :github_login
      t.string :name
      t.string :avatar_url

      t.timestamps
    end
    add_index :users, :github_id, unique: true
    add_index :users, :github_login, unique: true
  end
end
