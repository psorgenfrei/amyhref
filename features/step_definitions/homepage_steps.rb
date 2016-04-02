Given(/^I am not signed in$/) do
  visit root_path
  page.click_link('signout') if page.has_link?('signout')
end

When(/^I am on the homepage$/) do
  visit root_path
end

Then(/^I should see "([^"]*)"$/) do |arg1|
  page.should have_content(arg1)
end

Then(/^I should see some embedly cards$/) do
  #save_and_open_page
  page.should have_css('div.links')
  page.find('div.link').should have_css('a.embedly-card')
end
