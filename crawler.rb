require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"
require "date"
require "pry"
require "phantomjs"

Capybara.current_driver = :poltergeist

Capybara.configure do |config|
  config.run_server = false
  config.javascript_driver = :poltergeist
  config.app_host = "https://www.facebook.com/"
  config.default_max_wait_time = 120
  config.ignore_hidden_elements = false
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {:timeout=>120, :js=>true, :js_errors=>false,
  :phantomjs => Phantomjs.path,
  :phantomjs_options => ['--ssl-protocol=default', '--ignore-ssl-errors=false']})
end

include Capybara::DSL # 警告が出るが動く
page.driver.resize_window(1200, 10000)

visit "/"
fill_in "email", :with => ARGV[0]
fill_in "pass",  :with => ARGV[1]
find("button", text:"ログイン").trigger("click")
sleep 3
find("button", text:"OK").trigger("click")
visit "/saved/?dashboard_section=LINKS"
sleep 10

File.open("links.txt", "w+") do |f|
  all("#globalContainer #content_container #saveContentFragment ._ikh div div div a").each do |anchor|  
    hash = {title: anchor.text, href: anchor[:href]}
    next if anchor[:href] == "https://www.facebook.com/saved/?dashboard_section=LINKS#"
    f.puts(hash)
  end
end

delete_button_classes = 
  all("a i").map {|i| i[:class].split(" ")[2]}
    .reject {|item| item == "img" || item == "arrow" }
    .uniq.compact

delete_button_classes.each do |delete_button_class|
  all(".#{delete_button_class}").each do |delete_button|
    delete_button.trigger("click")
  end
end
