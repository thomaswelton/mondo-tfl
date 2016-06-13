class AddTimesToJourneys < ActiveRecord::Migration
  def change
    add_column :journeys, :tapped_in_mod, :int
    add_column :journeys, :tapped_out_mod, :int
  end
end
