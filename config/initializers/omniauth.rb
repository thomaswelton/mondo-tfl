Rails.application.config.middleware.use OmniAuth::Builder do
  provider :mondo, ENV['MONDO_CLIENT_ID'], ENV['MONDO_SECRET']
end
