class SessionsController < ApplicationController

  def create
    #raise request.env['omniauth.auth'].to_yaml
    auth = request.env['omniauth.auth']
    user = User.where(:"#{params[:provider]}_uid" => auth["uid"]) #check if we have this network for this user
    if user.count == 0
      if session[:user_id]
        user_id = User.create_with_omniauth(auth, session[:user_id])
      else
        user_id = User.create_with_omniauth(auth)
      end
    else
      user_id = user.first.id
    end
    session[:user_id] = user_id
    User.fetch_feed(user_id)
    redirect_to root_path, :notice => "Welcome #{user_id}"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, :notice => "Logged out"
  end

end
