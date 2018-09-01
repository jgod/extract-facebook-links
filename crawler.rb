require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"
require "pry"
require "phantomjs"
require_relative "facebook"
require_relative "links_organizer"
include LinksOrganizer

TEMP_FILE_NAME = "temp_links.txt"
LINKS_FILE_NAME = "links.txt"
TRIAL_COUNT = 50

fb = Facebook.new
fb.login_and_visit

begin
  TRIAL_COUNT.times do |time|
    fb.visit fb.current_url if time != 0
    fb.save_and_delete_links(time, TEMP_FILE_NAME, LINKS_FILE_NAME)
  end
rescue => e
  puts e
  exit
end

LinksOrganizer.unify_links(TEMP_FILE_NAME, LINKS_FILE_NAME)
