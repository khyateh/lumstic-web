##= require ./question_view
SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy category on the DOM
class SurveyBuilder.Views.Dummies.MultiRecordCategoryView extends SurveyBuilder.Views.Dummies.CategoryView
  limit_edit: =>
    super
    $(this.el).find("input[name=mandatory]").parent('div').hide()