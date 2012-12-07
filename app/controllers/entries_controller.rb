class EntriesController < ApplicationController

  def index
    if current_user
      user = current_user
      entries = current_user.entries.where(:viewed => false, :hidden => false)
      if entries.count > 2
        @enough = true
        @current = entries.first.video.vid
        @entry = entries.first
        @next = entries.second.video.vid
        @entry_n = entries.second
      else
        @enough = false
      end
    end
  end

  def next
    if current_user
      viewed = current_user.entries.where(:vid => params[:prev]).first
      viewed.viewed = true
      viewed.save
      entries = current_user.entries.where(:viewed => false, :hidden => false)
      @current = entries.first.video.vid
      @entry = entries.first
      @next = entries.second.video.vid
      @entry_n = entries.second
    end
    respond_to do |format|
      format.js { render :layout => false }
      format.html
    end

  end

end
