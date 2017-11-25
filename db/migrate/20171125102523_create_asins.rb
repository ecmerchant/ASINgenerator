class CreateAsins < ActiveRecord::Migration[5.0]
  def change
    create_table :asins do |t|
      t.text :user
      t.text :asin

      t.timestamps
    end
  end
end
