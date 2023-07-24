class AddIndexUsersNameUniqueTrue < ActiveRecord::Migration[6.1]
  def change
  end

  add_index :users, :name, unique: true
end
