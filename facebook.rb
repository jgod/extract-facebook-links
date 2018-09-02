require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"
require "pry"
require "phantomjs"
require_relative "config"

class Facebook
  include Config
  include Capybara::DSL # 警告が出るが動く

  def login_and_visit(email:, password:)
    Config.set_capybara
    visit "/"
    fill_in "email", :with => email
    fill_in "pass",  :with => password
    find("button", text:"ログイン").trigger("click")
    visit "/saved/?dashboard_section=LINKS"
    sleep 10
  end

  def visit_correct_url
    # たまに click のトリガー時に変なリンクを踏んでしまう
    visit "/saved/?dashboard_section=LINKS" unless
      current_url == "https://www.facebook.com/saved/?dashboard_section=LINKS"

    sleep 10
    count_links
  end

  def count_links
    @anchor_tags = all("#globalContainer #content_container #saveContentFragment ._ikh div div div a")
  end

  def delete_buttons
    delete_button_classes = 
      all("#globalContainer #content_container #saveContentFragment ._ikh div div div a i")
        .map {|i| i[:class].split(" ")[-1] }
        .reject {|item| item == "img" || item == "arrow" || item == "accessible_elem" }
        .uniq.compact

    delete_button_classes.each do |delete_button_class|
      all(".#{delete_button_class}").each do |delete_button|
        delete_button.trigger("click")
      end
    end

    puts ">>>>>> Deleted already saved links"
  end

  def save_links(temp_file, links_file)
    count_links

    if @anchor_tags.count == 0
      visit_correct_url
      return if @anchor_tags.count != 0

      puts ">>>>>> There is no saved links"
      LinksOrganizer.unify_links(temp_file, links_file)
      exit
    end

    File.open(temp_file, "a") do |f|
      @anchor_tags.each do |anchor|
        text = anchor.text.gsub!(" ", "") || "タイトルなし"
        href = anchor[:href]
        next if href == "https://www.facebook.com/saved/?dashboard_section=LINKS#"
        link = "[#{text} #{href}]"
        f.puts(link)
      end
    end

    puts ">>>>>> Saved links in links.txt"
  end

  def save_and_delete_links(time, temp_file, links_file)
    save_links(temp_file, links_file)
    delete_buttons
    sleep 10 if time != 0
  end
end
