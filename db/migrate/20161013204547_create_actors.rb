class CreateActors < ActiveRecord::Migration
  def change
    create_table :actors do |t|
      t.string :name
    end
  end
end
