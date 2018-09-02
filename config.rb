require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"
require "phantomjs"

module Config
  include Capybara::DSL # 警告が出るが動く
  def self.set_capybara
    Capybara.current_driver = :poltergeist

    Capybara.configure do |config|
      config.run_server = false
      config.javascript_driver = :poltergeist
      config.default_driver = :poltergeist
      config.app_host = "https://www.facebook.com/"
      config.default_max_wait_time = 120
      config.ignore_hidden_elements = false
    end

    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {:timeout=>120, :js=>true, :js_errors=>false,
      :phantomjs => Phantomjs.path,
      :phantomjs_options => ['--ssl-protocol=default', '--ignore-ssl-errors=false']})
    end
  end
end
