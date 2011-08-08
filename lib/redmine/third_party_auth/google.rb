require 'httparty'

module Redmine
  class Google
    def self.client_id
      if Rails.env == "development"
        "203479936712.apps.googleusercontent.com"
      else #if Rails.env == "production"
        "203479936712-tuci31s653t3llrtad27tcm1ot10rpja.apps.googleusercontent.com"
      end
    end

    def self.client_secret
      if Rails.env == "development"
        "_bwSbV_bfQ4JyuMGy5r_6m8e"
      else #if Rails.env == "production"
        "6-eyZhedETR_0oMuT2HnVUa6"
      end
    end

    def self.redirect_uri
      if Rails.env == "development"
        "http://manchego.favoritemedium.net:3000/oauth2callback"
      else #if Rails.env == "production"
        "http://rangoon.favoritemedium.net/redmine-yasith/oauth2callback"
      end
    end

    def self.sign_in_url
      "https://accounts.google.com/o/oauth2/auth?#{
      {
          :client_id => client_id, :redirect_uri => redirect_uri, :response_type => "code", :scope => "https://www.googleapis.com/auth/userinfo#email"
      }.to_query}"
    end

    def self.get_access_token_for_account_link code
      res = HTTParty.post("https://accounts.google.com/o/oauth2/token?", :body => {
          :client_id => client_id, :client_secret => client_secret,
          :redirect_uri => redirect_uri, :code => code, :grant_type => 'authorization_code'
      })

      res
    end

    def self.get_access_token code
      res = HTTParty.post("https://accounts.google.com/o/oauth2/token?", :body => {
          :client_id => client_id, :client_secret => client_secret,
          :redirect_uri => redirect_uri, :code => code, :grant_type => "authorization_code"
      })

      if res["error"]
        res
      else
        Rack::Utils.parse_nested_query(res) #for some weired reason httparty don't parse this correctly
      end
    end

    def self.get_user_info access_token
      HTTParty.get("https://www.googleapis.com/userinfo/email?alt=json",
            {:query =>  {:access_token => access_token} }
        )["data"]
    end
  end
end
