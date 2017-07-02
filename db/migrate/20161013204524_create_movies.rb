class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :name
      t.integer :year_released
      t.string :director
      t.string :format
      t.integer :user_id
    end
  end
end
