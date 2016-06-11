class DropTflUsernameAndPasswordFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :tfl_username
    remove_column :users, :tfl_password
  end
end
