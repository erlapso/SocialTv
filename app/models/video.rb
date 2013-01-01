class Video
  include Mongoid::Document

  field :url, :type => String
  field :vid, :type => String
  field :type, :type => String, :default => "youtube"
  field :likes, :type => Integer, :default => 0
  field :dislikes, :type => Integer, :default => 0
  field :views, :type => Integer, :default => 0
  field :hidden, :type => Boolean, :default => false
  field :category, :type => String, :default => "none"
  field :duration, :type => Integer
  field :title, :type => String
  field :description, :type => String
  field :comment_count, :type => Integer, :default => 0
  field :comments, :type => Array
  field :published_at, :type => DateTime

  has_many :entries

  def self.assign(link, entry_id)
    video = Video.where(:url => link)
    if video.count == 0
      a_v = Video.new
      a_v.url = link
      a_v.extract_vid
      a_v.save
      a_v.stats
    else
      a_v = video.first
    end
    entry = Entry.find(entry_id)
    entry.vid = a_v.vid
    entry.video = a_v
    entry.category = a_v.category
    if a_v.hidden == true
      entry.hidden = true
      entry.hidden_reason = "embed"
    end
    entry.save
  end

  def self.yt_assign(video, entry_id)
    vid = video.video_id.split(":").last
    ex_video = Video.where(:vid => vid)
    if ex_video.count == 0
      v = Video.new
      v.url = "http://www.youtube.com/watch?v=#{vid}"
      v.vid = vid
      v.save
      v.stats(video)
    else
      v = ex_video.first
    end
    entry = Entry.find(entry_id)
    entry.vid = vid
    entry.video = v
    entry.category = v.category
    if v.hidden == true
      entry.hidden = true
      entry.hidden_reason = "embed"
    end
    entry.save
  end

  def extract_vid
    vid = self.url.split("?")
    vid_t = vid[1].split("&")
    vid_s = vid_t[0].gsub("v=", "")
    puts vid_s
    self.vid = vid_s
    self.entries.each do |e|
      e.vid = vid_s
      e.save
    end
  end

  def self.vid(url)
    vid = url.split("?")
    if vid[1]
      vid_t = vid[1].split("&")
      vid_s = vid_t[0].gsub("v=", "")
    else
      vid_s = nil
    end
    vid_s
  end

  def stats(info=nil, comments=false)
    if not info
      yt = YouTubeIt::Client.new(:dev_key => YT[:dev_key]) 
      info = yt.video_by(self.vid)
    end
    if info.rating
      self.likes = info.rating.likes
      self.dislikes = info.rating.dislikes
    end
    self.views = info.view_count
    if info.access_control["embed"] == "denied"
      self.hidden = true
    end
    self.title = info.title
    self.description = info.description
    self.duration = info.duration
    self.category = info.categories.first.label
    self.comment_count = info.comment_count
    self.published_at = DateTime.parse(info.published_at.to_s)
    if self.comment_count > 10 
      yt = YouTubeIt::Client.new(:dev_key => YT[:dev_key]) if not yt
      cc = yt.comments(self.vid)
      comments = []
      cc.each_with_index do |comment, i| #fetch just the last 10 comments
        n_comment = { :author => comment.author.name, :content => comment.content, :published => comment.published }
        comments.push(n_comment)
      end
      self.comments = comments
    end
    self.save
  end

end
