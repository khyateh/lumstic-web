class AddPhotoProcessingToAnswers < ActiveRecord::Migration
  def change
  	add_column :answers, :photo_processing, :boolean, default: false
  end
end
