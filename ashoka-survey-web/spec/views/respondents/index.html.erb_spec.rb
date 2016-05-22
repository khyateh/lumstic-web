require 'spec_helper'

describe "respondents/index" do
  before(:each) do
    assign(:respondents, [
      stub_model(Respondent,
        :survey_id => 1,
        :user_id => 2,
        :respondent_json => "Respondent Json"
      ),
      stub_model(Respondent,
        :survey_id => 1,
        :user_id => 2,
        :respondent_json => "Respondent Json"
      )
    ])
  end

  it "renders a list of respondents" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Respondent Json".to_s, :count => 2
  end
end
