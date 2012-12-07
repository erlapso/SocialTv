class Youtube

  def self.user(id)
    user = User.find(id)
    client = YouTubeIt::OAuth2Client.new(client_access_token: user.yt_token, client_id: YT[:client_id], client_secret: YT[:client_secret], dev_key: YT[:dev_key])
    client
  end

  def self.get(id)
    user = Youtube.user(id)
    user_v = user.new_subscription_videos
    videos = user_v.videos
    videos
    end

  end

end
