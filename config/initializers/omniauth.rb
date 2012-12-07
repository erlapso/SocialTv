Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, FB[:app_id], FB[:app_secret],
  :scope => "email,read_stream", :display => "popup"
end
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :youtube, YT[:client_id], YT[:client_segret], {:access_type => 'online', :approval_prompt => ''}
end
