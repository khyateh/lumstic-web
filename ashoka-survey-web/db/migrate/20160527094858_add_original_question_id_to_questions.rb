class AddOriginalQuestionIdToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :original_question_id, :int
  end
end
