class CreateEvidences < ActiveRecord::Migration[5.0]
  def change
    create_table :evidences do |t|
      t.text :content
      t.references :node, foreign_key: true
      t.references :issue, foreign_key: true

      t.timestamps
    end
  end
end
