require 'spec_helper'

describe "Homepages" do
  describe "GET /homepages" do
    it "should load ok" do
      user = FactoryGirl.create(:user)

      get root_path
      response.status.should be(200)
    end

    it "should show some embedly cards" do
      user = FactoryGirl.create(:user)

      get root_path
      expect(response).to be_success
      expect(response).to render_template('index')
    end
  end
end
