require "lib/redmine/third_party_auth/facebook"
require "lib/redmine/third_party_auth/google"

class AuthCallbackController < AccountController
  def facebook
    if params[:error]
      flash.now[:error] = "Facebook login failed. Error message from Facebook: #{params[:error_reason]}, #{params[:error_description]}"
    else
      res = Redmine::Facebook.get_access_token_for_account_link params[:code], User.find_by_id(params[:user_id])

      unless res["error"]
        #success
        user_info = Redmine::Facebook.get_user_info res["access_token"]
        #facebook_authenticate(user_info)
        associate_facebook_account_with_user(user_info, params[:user_id])
      else
        #error
        flash.now[:error] = "Facebook login failed. Error message from Facebook: #{res["error"]["type"]}, #{res["error"]["message"]}"
      end
    end

    redirect_to(:back)
  end

  def google
    if params[:error]
      flash.now[:error] = "Google login failed. Error message from Google: #{params[:error_reason]}, #{params[:error_description]}"
    else
      res = Redmine::Google.get_access_token_for_account_link params[:code]

      unless res["error"]
        #success
        user_info = Redmine::Google.get_user_info res["access_token"]
        #google_authenticate(user_info)
        if User.current.type != "AnonymousUser" && User.current.type != AnonymousUser
          associate_google_account_with_user(user_info, User.current)
          redirect_to(:controller => "my", :action => "account")
        else
           #internal_redirect_to(:controller => "account", :action => "google_callback", :code => params[:code])
          #HTTParty.get("http://127.0.0.1:3000/account/google_callback?code=#{params[:code]}")
          google_authenticate user_info
        end
      else
        #error
        flash.now[:error] = "Google login failed. Error message from Google: #{res["error"]["type"]}, #{res["error"]["message"]}"
        redirect_to(:controller => "my", :action => "account")
      end
    end
  end

  def unlink_google
    user = User.current
    user.google_email = nil
    user.save

    redirect_to(:controller => "my", :action => "account")
  end

  def unlink_facebook
    user = User.current
    user.facebook_id = nil
    user.save

    redirect_to(:controller => "my", :action => "account")
  end

  private
  def associate_google_account_with_user user_info, user
    user.google_email = user_info["email"]
    user.save
  end

  def associate_facebook_account_with_user user_info, user_id
    user = User.find_by_id user_id
    user.facebook_id = user_info["id"]
    user.save
  end
end