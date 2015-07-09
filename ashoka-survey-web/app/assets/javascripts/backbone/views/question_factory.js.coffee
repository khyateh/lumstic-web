class SurveyBuilder.Views.QuestionFactory extends Backbone.View
  @Types = {
    SINGLE_LINE : 'SingleLineQuestion',
    MULTILINE : 'MultilineQuestion',
    NUMERIC :'NumericQuestion',
    DATE : 'DateQuestion',
    RADIO : 'RadioQuestion',
    MULTI_CHOICE : 'MultiChoiceQuestion',
    DROP_DOWN : 'DropDownQuestion',
    PHOTO : 'PhotoQuestion'
    RATING : 'RatingQuestion',
    MULTI_RECORD : 'MultiRecordCategory',
    CATEGORY : null
  }

  @is_with_options: (type) =>
    type in [@Types.RADIO, @Types.MULTI_CHOICE, @Types.DROP_DOWN]

  @dummy_view_for: (type, model, survey_frozen) =>
    type = null unless type
    switch type
      when @Types.SINGLE_LINE
        template = $('#dummy_single_line_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template, survey_frozen)
      when @Types.MULTILINE
        template = $('#dummy_multiline_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template, survey_frozen)
      when @Types.NUMERIC
        template = $('#dummy_numeric_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template, survey_frozen)
      when @Types.DATE
        template = $('#dummy_date_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template, survey_frozen)
      when @Types.RADIO
        template = $('#dummy_radio_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(model, template, survey_frozen)
      when @Types.MULTI_CHOICE
        template = $('#dummy_multi_choice_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(model, template, survey_frozen)
      when @Types.DROP_DOWN
        template = $('#dummy_drop_down_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(model, template, survey_frozen)
      when @Types.PHOTO
        template = $('#dummy_photo_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template, survey_frozen)
      when @Types.RATING
        template = $('#dummy_rating_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template, survey_frozen)
      when 'MultiRecordQuestion'
        template = $('#dummy_multi_record_question_template').html()
        return new SurveyBuilder.Views.Dummies.MultiRecordQuestionView(model, null, survey_frozen)
      when @Types.CATEGORY
        if model instanceof SurveyBuilder.Models.CategoryModel
          template = $('#dummy_category_template').html()
          return new SurveyBuilder.Views.Dummies.CategoryView(model, template, survey_frozen)
      when @Types.MULTI_RECORD
        template = $('#dummy_multi_record_category_template').html()
        return new SurveyBuilder.Views.Dummies.MultiRecordCategoryView(model, template, survey_frozen)

  @model_for: (attrs) =>
    attrs.type = null unless attrs.type
    if (@is_with_options(attrs.type))
      new SurveyBuilder.Models.QuestionWithOptionsModel(attrs)
    else if  attrs.type == @Types.CATEGORY
      new SurveyBuilder.Models.CategoryModel(attrs)
    else if  attrs.type == @Types.MULTI_RECORD
      new SurveyBuilder.Models.MultiRecordCategoryModel(attrs)
    else
      new SurveyBuilder.Models.QuestionModel(attrs)
