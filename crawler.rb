require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"
require "pry"
require "phantomjs"
require_relative "facebook"

fb = Facebook.new
fb.login_and_visit

1.times do |time|
  fb.visit current_url if time != 0
  fb.save_and_delete_links(time)
end
