class AddCurrentCardReferenceToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :current_card
  end
end
