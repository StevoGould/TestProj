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
    class WebDriverListener
      def har_present
        begin
          @client.har
        rescue JSON::ParserError => e
          false
        else
          true
        end
      end

      def before_navigate_to(url, driver)
        save_har if har_present # first request
        @client.new_har("navigate-to-#{url}", @new_har_opts)
        @current_url = url
      end

      def before_quit(driver)
        #save_har
      end
    end

  end

end

