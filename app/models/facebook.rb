class Facebook

  def self.get(id, object, fields=nil, auto=false)
    user = User.find(id)
    token = user.fb_token
    if auto == true
      fields = []
      if user.fb_until
          f_since = "since=#{user.fb_until}"
          new_since = user.fb_until
      else
        f_since = "since=#{(Time.now-3.days).to_i}"
        new_since = (Time.now-6.days).to_i 
      end
      f_until = "until=#{(Time.now).to_i}"
      new_until = Time.now.to_i
      fields.push(f_since)
      fields.push(f_until)
      user.fb_since = new_since
      user.fb_until = new_until
      user.save
    end
    if fields
      fields = fields.join('&')
      fields = "&#{fields}"
    end
    feed = HTTParty.get("https://graph.facebook.com/#{user.facebook_uid}/#{object}?access_token=#{token}#{fields}")
    feed.first.second
  end

end
