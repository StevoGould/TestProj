require 'selenium/webdriver'
require 'capybara'
require 'capybara'
require 'capybara/cucumber'
require 'capybara/dsl'
require 'capybara/rspec'
require 'cucumber'
require 'cucumber/rake/task'
require 'rspec'
require 'selenium/webdriver'
require 'browsermob/proxy'
require 'browsermob/proxy/webdriver_listener'
require 'json'



#url = "https://girishp1:kspUszvG7UsGZKXvUBFr@hub.browserstack.com/wd/hub"
#capabilities = Selenium::WebDriver::Remote::Capabilities.new
#
#
#capabilities['platform'] = 'WINDOWS'
#capabilities['browser'] =  'chrome'
#
##capabilities['browserName'] = 'iPhone'
##capabilities['platform'] = 'MAC'
##capabilities['device'] = 'iPhone 5'
#
#
#
#
#capabilities['browser_version'] = ENV['SELENIUM_VERSION'] if ENV['SELENIUM_VERSION']
#capabilities['browserstack.local'] = 'true'
#capabilities['proxy'] = 'DEV01ISA01:8080'
#capabilities['acceptSslCerts'] = 'true'
#capabilities['browserstack.debug'] = 'true'
#
module BrowserMob
  module Proxy
    class Client
      def self.from(server_url)
        port = JSON.parse(
            RestClient.post(URI.join(server_url, "proxy?httpProxy=dev01isa01:8080").to_s, '')
        ).fetch('port')

        uri = URI.parse(File.join(server_url, "proxy", port.to_s))
        resource = RestClient::Resource.new(uri.to_s)

        Client.new resource, uri.host, port
      end
    end
  end
end

server = BrowserMob::Proxy::Server.new("D:\\My\\Tools\\BP\\browsermob-proxy-2.0-beta-9\\bin\\browsermob-proxy.bat",:port => 9090, :log => true) #=> #<BrowserMob::Proxy::Server:0x000001022c6ea8 ...>
server.start
proxy = server.create_proxy #=> #<BrowserMob::Proxy::Client:0x0000010224bdc0 ...>
#proxy.new_har "goo"
#proxy_listener = BrowserMob::Proxy::WebDriverListener.new(proxy)
#driver = Selenium::WebDriver.for :firefox, :profile => profile, :listener => proxy_listener
proxy_listener = BrowserMob::Proxy::WebDriverListener.new(proxy)

  Capybara.register_driver :selen_stack do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.proxy = proxy.selenium_proxy
   # profile["network.proxy.type"] = 4
    #Selenium::WebDriver.for :firefox, :profile => profile, :listener => proxy_listener
    #Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
    Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile, :listener => proxy_listener)
  end


After do
  # JSON.parse(proxy.har.to_json)['log']['entries'].each {|entry| perf['log']['entries'] << entry}
end

#Has to update the hars method in proxy_listener as it was not capturing traffic of all the requests,
#it was just getting the last one which was always empty
#
at_exit do
 # File.open("google.har", "w") { |io|  io <<  HAR::Archive.by_merging(proxy_listener.hars).to_json }
  #File.open("google.har", "w") { |io|  proxy_listener.hars.each { |data| io <<  data.to_json} }
  #File.open("google.har", "w") { |io|  io <<  proxy.har.to_json }
  #proxy.har.save_to "goo.har"
  proxy_listener.hars.each {|data| data.save_to "goo.har"}
  proxy.close
  server.stop
end

Capybara.configure do |config|
  config.run_server = false
  config.current_driver = :selen_stack
  config.javascript_driver = :selen_stack
  config.default_wait_time = 30
  config.app_host = "http://tesco.lawrenceapplications.co.uk"
end




