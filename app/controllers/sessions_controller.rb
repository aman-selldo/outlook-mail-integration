class SessionsController < ApplicationController

  def microsoft_auth
    auth = request.env['omniauth.auth']
    
    user = User.find_or_initialize_by(microsoft_uid: auth.uid)
    
    user.name = auth.info.name
    user.email = auth.info.email if auth.info.email.present?
    user.token = auth.credentials.token
    user.refresh_token = auth.credentials.refresh_token
    user.expires_at = Time.at(auth.credentials.expires_at)
    user.save
    
    session[:user_id] = user.id
    redirect_to emails_path, notice: "Signed in successfully!"
  end

  def failure    
    redirect_to root_path, alert: "Authentication failed"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Signed out successfully"
  end
end
