require 'zip'

class Reports::Excel::Job < Struct.new(:excel_data)

  def start
    @delayed_job ||= Delayed::Job.enqueue(self, :queue => 'generate_excel')
  end

  def perform
    Zip.default_compression = ::Zlib::DEFAULT_COMPRESSION
    Tempfile.open(excel_data.file_name + ".zip", Rails.root.join('tmp')) do |f|
    f.binmode
    
    buffer = Zip::OutputStream.write_buffer(::StringIO.new(''),  Zip::TraditionalEncrypter.new(excel_data.password)) do |zos|
       zos.put_next_entry(excel_data.file_name + ".xlsx")
       if excel_data.responses.count > 0
        zos.write package.to_stream.read
       end 
     end.string
     
      f.write buffer 
      f.rewind
      f.close
            
      directory = aws_excel_directory
      directory.files.create(:key => excel_data.file_name + ".zip", :body => f.open, :public => true)
    end
  end

  # REFACTOR: Use a `sheet` abstraction which internally adds all its rows to a AXSLX worksheet
  # REFACTOR: Use a `style` abstraction
  def package
    return if excel_data.responses.empty?
    Axlsx::Package.new do |p|
      @categories = nil
      wb = p.workbook
      bold_style = wb.styles.add_style sz: 12, b: true, alignment: { horizontal: :center }
      border = wb.styles.add_style border: { style: :thin, color: '000000' }
      questions = excel_data.questions.map(&:reporter)
      hasMultiRecord = SurveyHasMultiRecord excel_data.survey.id      
      wb.add_worksheet(name: "Responses") do |sheet|
        headers = Reports::Excel::Row.new("Response No.")
        headers << questions.map(&:header)
        headers << excel_data.metadata.headers
        sheet.add_row headers.to_a, :style => bold_style
        excel_data.responses.each_with_index do |response, i|
          response_answers =  Answer.where(:response_id => response[:id])
          .order('answers.record_id')
          .includes(:choices => :option).all
          # Check for multiple category ids and duplicate question ids in the response -> map to new rows
          #multi_answers = response_answers.group(:question_id).having("count(id) > 1")          
          #multi_rec_questions = Question.where(:survey_id => excel_data.survey.id).includes('categories').where(:type => "MultiRecordCategory")
          record_ids = Array.new
          if hasMultiRecord
            @categories.each do |cat| 
              @records = Record.where(:response_id => response[:id], :category_id => cat.id)            
            end
            if (@records)
              first_record = @records.first
              @records.reject {@records.first}
            end
            
            @multi_rec_answers = Answer.new
            @records.each do |record|
              record_ids.push record.id
             
             # Rails.logger.debug response_answers.where(:record_id => record.id).count == 0? nil : response_answers.where(:record_id => record.id)  
              #@multi_rec_answers.concat response_answers.where(:record_id => record.id) 
              # Remove the answers that have record_ids after the first record_id; include those answers in next lines
              response_answers.reject{ |a| a.record_id == record.id}            
            end
            @multi_rec_answers = Answer.where(:response_id => response[:id], :record_id => record_ids)            
            id_answers = Answer.includes(:question).where(questions: { :identifier => true }, :response_id => response[:id])
          end
          answers_row = Reports::Excel::Row.new(i + 1)
          answers_row << questions.map do |question|
            question_answers = response_answers.find_all { |a| a.question_id == question.id }
            question.formatted_answers_for(question_answers, :server_url => excel_data.server_url)
          end
          answers_row << excel_data.metadata.for(response)
          sheet.add_row answers_row.to_a, style: border

          if (hasMultiRecord && @multi_rec_answers && record_ids.length > 1) # && @multi_rec_answers.count > 0)
            record_ids.each do |rec|
              multi_answers_row = Reports::Excel::Row.new(i + 1)
              multi_answers_row << questions.map do |question|
                question_answers = id_answers.find_all { |a| a.question_id == question.id }
                if (question_answers.length <= 0)
                  question_answers = @multi_rec_answers.find_all { |a| a.question_id == question.id && a.record_id == rec }
                end
                question.formatted_answers_for(question_answers, :server_url => excel_data.server_url)                               
              end
              multi_answers_row << excel_data.metadata.for(response)
              sheet.add_row multi_answers_row.to_a, style: border
            end
          end
        end
       end
    end
  end

  def delayed_job_id
    @delayed_job.id
  end

  def error(job, exception)
    #puts exception
    Airbrake.notify(exception)
  end

  def SurveyHasMultiRecord(surveyId)
    @categories = Category.where(:survey_id => surveyId, :type => "MultiRecordCategory")
    return (@categories.count > 0)
  end

  private

  def aws_excel_directory
    connection = Fog::Storage.new(:provider => "AWS",
                                  :aws_secret_access_key => ENV['S3_SECRET'],
                                  :aws_access_key_id => ENV['S3_ACCESS_KEY'])
    connection.directories.get('surveywebdevelopmentassets')
    #TODO - Replace with surveywebexcel for prod
  end
end
