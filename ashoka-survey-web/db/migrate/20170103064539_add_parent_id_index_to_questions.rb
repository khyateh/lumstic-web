class AddParentIdIndexToQuestions < ActiveRecord::Migration
  def change
    add_index "questions", ["parent_id"], :name => "index_questions_on_parent_id"
  end
end
