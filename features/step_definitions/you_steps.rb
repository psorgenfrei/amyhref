Given(/^I am logged in as amyhref@gmail\.com$/) do
  user = User.where(email: 'amyhref@gmail.com').first
  page.set_rack_session(current_user: user.id)
end

When(/^I visit the homepage$/) do
  visit root_path
end

When(/^I click on You$/) do
  page.click_link('You')
end

Then(/^I should be on my highlights page$/) do
  current_path == you_highlights_path
end

Then(/^I should see a Home link$/) do
  page.should have_css('a.home')
end

Then(/^I should see an All link$/) do
  page.should have_css('a.highlights')
end
