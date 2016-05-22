class CreateRespondents < ActiveRecord::Migration
  def change
    create_table :respondents do |t|
      t.integer :survey_id
      t.integer :user_id
      t.string :respondent_json

      t.timestamps null: false
    end
  end
end
