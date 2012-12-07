class User
  include Mongoid::Document

  field :name, :type => String
  field :email, :type => String
  field :image, :type => String

  #FACEBOOK
  field :facebook_uid, :type => Integer
  field :fb_token, :type => String
  field :fb_since, :type => Integer
  field :fb_until, :type => Integer
  field :fb_image, :type => String
  field :fb_email, :type => String
  field :fb_first_name, :type => String
  field :fb_last_name, :type => String

  #YOUTUBE
  field :youtube_uid, :type => String
  field :yt_email, :type => String
  field :yt_location, :type => String, :default => "EN"
  field :yt_channel_title, :type => String
  field :yt_token, :type => String 
  field :yt_nickname, :type => String
  field :yt_image, :type => String

  #settings
  field :hide_music, :type => Boolean, :default => true

  has_many :entries   

  def dev
    self.entries.each do |c|
    c.viewed = false
    c.save
    end
  end

  def fb_extract(entry)
    if entry["link"]
      if entry["link"].include?("youtube.com")
        v = Entry.new
        v.author = entry["from"]["name"]
        v.author_image = "https://graph.facebook.com/#{entry["from"]["id"]}/picture"
        v.created_time = DateTime.parse(entry["created_time"].to_s)
        v.message = entry["message"] if entry["message"]
        v.fb_likes = entry["likes"] if entry["likes"]
        v.fb_comments = entry["comments"] if entry["comments"]
        v.fb_shares = entry["shares"] if entry["shares"]
        v.save
        Video.assign(entry["link"], v.id)
        final = v.id
      else
        final = nil
      end
    end
    return final
  end

  def yt_extract(video)
    e = Entry.new
    e.author = video.author.name
    e.message = video.description
    e.created_time = DateTime.parse(video.published_at.to_s)
    e.save
    Video.yt_assign(video, e.id)
    final = e.id
    final
  end

  def fb_check_valid_entries
    entries = self.entries.where(:viewed => false, :hidden => false).count
    if entries < 2
      options = []
      f_since = self.fb_since - (3.days.to_i) if self.fb_since
      f_until = self.fb_since if self.fb_since
      options.push(f_since)
      options.push(f_until)
      User.fetch_feed(self.id, options, false, false)
    end
  end

  def solidify
    if not self.image
      self.image = self.fb_image if self.fb_image
      self.image = self.yt_image if self.yt_image
    end
    if not self.name
      self.name = self.fb_first_name if self.fb_first_name
      self.name = self.yt_nickname if self.yt_nickname
    end
  end

  def self.fetch_feed(id, options=nil, auto=true, check=true)
    user = User.find(id)
    if user.fb_token
      stream = Facebook.get(id, "home", options, auto)
      stream.each do |entry|
        if entry["link"] && user.entries.where(:"video.url" => entry["url"]).count == 0
          e = user.fb_extract(entry)
          if e
            entry = Entry.find(e)
            if user.hide_music == true && entry.video.category
              entry.hidden = true
              entry.hidden_reason = "music"
              entry.save
            end
            user.entries.push(entry)
          end
        end
      end
      user.fb_check_valid_entries if check
    end
    if user.yt_token
      stream = Youtube.get(id)
      stream.each do |video|
        entry = user.yt_extract(video)
        e = Entry.find(entry)
        user.entries.push(e)
      end
    end 
  end

  def self.create_with_omniauth(auth, id=nil)
    if id
      user = User.find(id)
    else
      user = User.new
    end
    if auth["provider"] == "facebook"
      user.facebook_uid = auth["uid"].to_i
      user.fb_first_name = auth["info"]["first_name"]
      user.fb_last_name = auth["info"]["last_name"]
      user.fb_email = auth["info"]["email"]
      user.fb_image = auth["info"]["image"]
      user.fb_token = auth["credentials"]["token"]
    end
    if auth["provider"] == "youtube"
      user.youtube_uid = auth["uid"]
      user.yt_nickname = auth["info"]["nickname"]
      user.yt_email = auth["info"]["email"]
      user.yt_channel_title = auth["info"]["channel_title"]
      user.yt_token = auth["credentials"]["token"]
    end
    user.save
    user.solidify
    user.id
  end

end
