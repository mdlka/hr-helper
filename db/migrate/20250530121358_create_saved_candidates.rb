class CreateSavedCandidates < ActiveRecord::Migration[8.0]
  def change
    create_table :saved_candidates do |t|
      t.references :user, null: false, foreign_key: true
      t.references :resume, null: false, foreign_key: true

      t.timestamps
    end
  end
end
