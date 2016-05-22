require "spec_helper"

describe RespondentsController do
  describe "routing" do

    it "routes to #index" do
      get("/respondents").should route_to("respondents#index")
    end

    it "routes to #new" do
      get("/respondents/new").should route_to("respondents#new")
    end

    it "routes to #show" do
      get("/respondents/1").should route_to("respondents#show", :id => "1")
    end

    it "routes to #edit" do
      get("/respondents/1/edit").should route_to("respondents#edit", :id => "1")
    end

    it "routes to #create" do
      post("/respondents").should route_to("respondents#create")
    end

    it "routes to #update" do
      put("/respondents/1").should route_to("respondents#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/respondents/1").should route_to("respondents#destroy", :id => "1")
    end

  end
end
