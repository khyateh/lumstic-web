class AddParentIdToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :parent_id, :integer
  end
end
