require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"
require "pry"
require "phantomjs"
require_relative "config"

class Facebook
  include Config
  include Capybara::DSL # 警告が出るが動く

  def login_and_visit
    Config.set_capybara
    visit "/"
    fill_in "email", :with => ARGV[0]
    fill_in "pass",  :with => ARGV[1]
    find("button", text:"ログイン").trigger("click")
    sleep 3
    find("button", text:"OK").trigger("click")
    visit "/saved/?dashboard_section=LINKS"
    sleep 10
  end

  def delete_buttons
    delete_button_classes = 
      all("a i").map {|i| i[:class].split(" ")[2]}
        .reject {|item| item == "img" || item == "arrow" }
        .uniq.compact

    delete_button_classes.each do |delete_button_class|
      all(".#{delete_button_class}").each do |delete_button|
        delete_button.trigger("click")
      end
    end

    puts "Deleted already saved links"
  end

  def save_links
    anchor_tags = all("#globalContainer #content_container #saveContentFragment ._ikh div div div a")

    if anchor_tags.count == 0
      puts "保存済みの動画はありません。"
      exit
    end

    File.open("links.txt", "w+") do |f|
      anchor_tags.each do |anchor|
        text = anchor.text.gsub!(" ", "") || "タイトルなし"
        href = anchor[:href]
        next if href == "https://www.facebook.com/saved/?dashboard_section=LINKS#"
        link = "[#{text} #{href}]"
        f.puts(link)
      end
    end

    puts "Saved links in links.txt"
  end

  def save_and_delete_links(time)
    save_links
    delete_buttons
    sleep 10 if time != 0
  end
end
