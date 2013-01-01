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
      fin = refresh_user(auth)   
   end
    session[:user_id] = user_id
    if not fin
      redirect_to root_path
    else
      redirect_to fin
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, :notice => "Logged out"
  end

  def refresh_user(auth)
    url = nil
    tok = "#{auth["provider"]}_token".to_sym
    refresh_user = User.where(:"#{auth["provider"]}_uid" => auth["uid"]).first
    refresh_user[tok] = auth["credentials"]["token"]
    refresh_user.last_login = DateTime.now
    refresh_user.save
    PROVIDERS.each do |provider|
      if not provider == auth["provider"]
        if refresh_user["#{provider}_token"]
          if refresh_user["#{provider}_token_expires_at"] > (DateTime.now-3.hours).to_i
            url = "/auth/#{provider}/"
          end
        end
      end
    end
    url
  end

end
