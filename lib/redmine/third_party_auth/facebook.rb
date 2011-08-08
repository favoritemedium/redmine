require 'httparty'

module Redmine
  class Facebook
    def self.client_id
      if Rails.env == "development"
        "119346408153517"
      else #if Rails.env == "production"
        "135847556501739"
      end
    end

    def self.client_secret
      if Rails.env == "development"
        "0cf0e2a577b886912ef40b99ccef3f6c"
      else #if Rails.env == "production"
        "0db3f966f11c33954b54501a0a81be1b"
      end
    end

    def self.redirect_uri
      if Rails.env == "development"
        "http://manchego.favoritemedium.net:3000/account/facebook_callback"
      else #if Rails.env == "production"
        "http://favoritemedium.com:8080/redmine-dev2/account/facebook_callback"
      end
    end

    def self.account_link_redirect_uri user
      if Rails.env == "development"
        "http://manchego.favoritemedium.net:3000/facebook_callback?user_id=#{user.id}"
      else #if Rails.env == "production"
        "http://favoritemedium.com:8080/redmine-dev2/facebook_callback?user_id=#{user.id}"
      end
    end

    def self.sign_in_url
      "https://www.facebook.com/dialog/oauth?client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=email"
    end

    def self.account_link_url user
      "https://www.facebook.com/dialog/oauth?client_id=#{client_id}&redirect_uri=#{account_link_redirect_uri(user)}&scope=email"
    end

    def self.get_access_token_for_account_link code, user
      res = HTTParty.post("https://graph.facebook.com/oauth/access_token?", :body => {
          :client_id => client_id, :client_secret => client_secret,
          :redirect_uri => account_link_redirect_uri(user), :code => code
      })

      if res["error"]
        res
      else
        Rack::Utils.parse_nested_query(res) #for some qired reason httparty don't parse this correctly
      end
    end

    def self.get_access_token code
      res = HTTParty.post("https://graph.facebook.com/oauth/access_token?", :body => {
          :client_id => client_id, :client_secret => client_secret,
          :redirect_uri => redirect_uri, :code => code
      })

      if res["error"]
        res
      else
        Rack::Utils.parse_nested_query(res) #for some qired reason httparty don't parse this correctly
      end
    end

    def self.get_user_info access_token
      HTTParty.get("https://graph.facebook.com/me",
            {:query =>  {:access_token => access_token} }
        )
    end
  end
end