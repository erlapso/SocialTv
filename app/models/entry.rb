class Entry
  include Mongoid::Document

  field :author, :type => String
  field :author_image, :type => String
  field :fb_likes, :type => Integer, :default => 0
  field :fb_comments, :type => Integer, :default => 0
  field :fb_shares, :type => Integer, :default => 0
  field :viewed, :type => Boolean, :default => false
  field :vid, :type => String
  field :created_time, :type => DateTime
  field :title, :type => String
  field :message, :type => String

  field :hidden, :type => Boolean, :default => false
  field :hidden_reason, :type => String

  belongs_to :video

  belongs_to :user

end
