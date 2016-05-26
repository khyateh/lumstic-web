class AddFieldsToRespondents < ActiveRecord::Migration
  def change
    add_column :respondents, :response_id, :integer
    add_column :respondents, :organization_id, :integer
    add_column :respondents, :location, :string
  end
end
