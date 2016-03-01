Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.secrets.client_id, Rails.application.secrets.client_secret, {
    scope: "email, profile, https://mail.google.com/",
    #prompt: "consent",
    access_type: 'offline',
    skip_jwt: true
  }
end
