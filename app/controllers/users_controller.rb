class UsersController < ApplicationController
  def settings
    v = current_user.option[params[:option]]
    if v == true
      value = false
    else
      value = true
    end
    puts value
    user = User.find(session[:user_id])
    user.option["#{params[:option].to_s}"] = value
    user.save
    response = { "value" => value, "opposite" => v }
    respond_to do |format|
      format.js { render :json => response.to_json }
    end
  end
end
