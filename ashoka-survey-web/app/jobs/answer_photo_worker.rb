class AnswerPhotoWorker < CarrierWave::Workers::ProcessAsset
  def after(job)
    answer = Answer.find(id)
    answer.update_photo_size!
  end
end
