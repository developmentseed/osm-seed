# Configure ActionMailer SMTP settings
ActionMailer::Base.smtp_settings = {
  :address => ENV['MAILER_ADDRESS'],
  :port => 587,
  :domain => ENV['MAILER_DOMAIN'],
  :user_name => ENV['MAILER_USERNAME'],
  :password => ENV['MAILER_PASSWORD'],
  :authentication => 'login',
  :enable_starttls_auto => true
}

# Set the host and protocol for all ActionMailer URLs
ActionMailer::Base.default_url_options = {
  :host => ENV['SERVER_URL'],
  :protocol => ENV['SERVER_PROTOCOL']
}