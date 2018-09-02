require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"
require "pry"
require "phantomjs"
require "json"
require_relative "facebook"
require_relative "links_organizer"
include LinksOrganizer

facebook_login_info =
  JSON.load(File.read("/home/ec2-user/extract-facebook-links/facebook_login_info.json"))

EMAIL = facebook_login_info["email"]
PASSWORD = facebook_login_info["password"]
TEMP_FILE_NAME = "temp_links.txt"
LINKS_FILE_NAME = "links.txt"
TRIAL_COUNT = 50

fb = Facebook.new
fb.login_and_visit(email: EMAIL, password: PASSWORD)

TRIAL_COUNT.times do |time|
  fb.visit fb.current_url if time != 0
  fb.save_and_delete_links(time, TEMP_FILE_NAME, LINKS_FILE_NAME)
end

LinksOrganizer.unify_links(TEMP_FILE_NAME, LINKS_FILE_NAME)
