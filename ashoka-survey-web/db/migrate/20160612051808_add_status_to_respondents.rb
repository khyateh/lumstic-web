class AddStatusToRespondents < ActiveRecord::Migration
  def change
    add_column :respondents, :status, :string
  end
end
