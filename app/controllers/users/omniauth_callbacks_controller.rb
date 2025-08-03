class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]
    
    if auth.nil?
      redirect_to new_user_session_path, alert: "Authentication failed. Please try again."
      return
    end

    @user = User.from_omniauth(auth)

    if @user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.google_data"] = auth.except(:extra) if auth
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "Authentication failed. Please try again."
  end
end