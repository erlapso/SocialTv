class EntriesController < ApplicationController

  def index
    if current_user
      if params[:fetch]
        r = User.fetch_feed(current_user.id)
      end 
      entries = current_user.entries.desc(:creation_time)
      entries = entries.where(:viewed => false) if current_user.option["hide_watched_videos"] == true
      entries = entries.where(:"video.category".ne => "Music") if current_user.option["hide_watched_videos"] == true
      if params[:prev]
        viewed = current_user.entries.where(:vid => params[:prev]).first
        viewed.viewed = true
        viewed.save
      end
      if entries.count > 2
        @enough = true
        if params[:next]
          @entry = entries.where(:vid => params[:next]).first
        else
          @entry = entries.first
        end
        @next = entries.second
        @data = ["published_at", "views", "likes", "dislikes"]
        sec = ["fb_likes", "fb_comments", "fb_shares"]
        @data = @data.concat(sec) if @entry.source == "facebook"
      else
        @enough = false
      end
    end
    respond_to do |format|
      format.html {
        if r
        redirect_to "/auth/#{r}/"
        end
      }
      format.js { "success" }
    end
  end

end
