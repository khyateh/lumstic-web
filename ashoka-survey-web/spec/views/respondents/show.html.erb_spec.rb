require 'spec_helper'

describe "respondents/show" do
  before(:each) do
    @respondent = assign(:respondent, stub_model(Respondent,
      :survey_id => 1,
      :user_id => 2,
      :respondent_json => "Respondent Json"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Respondent Json/)
  end
end
