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
      redirect_to(:controller => "my", :action => "account")
    else
      res = Redmine::Google.get_access_token_for_account_link params[:code]

      unless res["error"]
        #success
        user_info = Redmine::Google.get_user_info res["access_token"]
        #google_authenticate(user_info)
        if User.current.type != "AnonymousUser" && User.current.type != AnonymousUser
          @email = session[:google_auth_email] = user_info["email"]
        else
          google_authenticate user_info
        end
      else
        #error
        flash.now[:error] = "Google login failed. Error message from Google: #{res["error"]["type"]}, #{res["error"]["message"]}"
        redirect_to(:controller => "my", :action => "account")
      end
    end
  end

  def google_confirm
    unless session[:google_auth_email].blank?
      associate_google_account_with_user(session[:google_auth_email], User.current)
    end
    redirect_to(:controller => "my", :action => "account")
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
  def associate_google_account_with_user email, user
    user.google_email = email
    user.save
  end

  def associate_facebook_account_with_user user_info, user_id
    user = User.find_by_id user_id
    user.facebook_id = user_info["id"]
    user.save
  end
end