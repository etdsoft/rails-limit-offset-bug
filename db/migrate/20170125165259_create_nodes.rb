class CreateNodes < ActiveRecord::Migration[5.0]
  def change
    create_table :nodes do |t|
      t.string :label
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
