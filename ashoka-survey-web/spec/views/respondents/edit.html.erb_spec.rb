require 'spec_helper'

describe "respondents/edit" do
  before(:each) do
    @respondent = assign(:respondent, stub_model(Respondent,
      :survey_id => 1,
      :user_id => 1,
      :respondent_json => "MyString"
    ))
  end

  it "renders the edit respondent form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => respondents_path(@respondent), :method => "post" do
      assert_select "input#respondent_survey_id", :name => "respondent[survey_id]"
      assert_select "input#respondent_user_id", :name => "respondent[user_id]"
      assert_select "input#respondent_respondent_json", :name => "respondent[respondent_json]"
    end
  end
end
