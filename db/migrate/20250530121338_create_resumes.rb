class CreateResumes < ActiveRecord::Migration[8.0]
  def change
    create_table :resumes do |t|
      t.text :content
      t.text :summary
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
