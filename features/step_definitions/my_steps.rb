Given(/^I am on home page$/) do
  visit "/"
end

Then(/^I should have title$/) do

end

When /^I search for "(.*)"$/ do |sear|
  page.find('input.search_bar').set sear
  page.find('button.fa-search').click
end

Then /^I should be on search results page$/ do
 page.current_url.should have_content('Search')
 page.should have_css('.products')
end