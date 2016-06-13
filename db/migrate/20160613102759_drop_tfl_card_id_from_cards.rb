class DropTflCardIdFromCards < ActiveRecord::Migration
  def change
    remove_column :cards, :tfl_card_id
  end
end
