class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :title
      t.string :subtitle
      t.text :context
      t.text :problem
      t.text :solution
      t.text :outcome
      t.string :github_url

      t.timestamps
    end
  end
end
