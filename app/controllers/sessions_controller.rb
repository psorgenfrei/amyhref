class SessionsController < ApplicationController
  layout false

  def new
  end

  def create
    raw_data = request.env["omniauth.auth"].extra.raw_info

    if User.exists?(email: raw_data.email)
      @user = User.where(email: raw_data.email).first

      @user.update_attributes(
        name: raw_data.name,
        email: raw_data.email,
        first_name: raw_data.given_name,
        last_name: raw_data.family_name,
        picture: raw_data.picture,
        profile: raw_data.profile
      )
    else
      @user = User.create(
        name: raw_data.name,
        email: raw_data.email,
        first_name: raw_data.given_name,
        last_name: raw_data.family_name,
        picture: raw_data.picture,
        profile: raw_data.profile
      )
    end

    @auth = request.env['omniauth.auth']['credentials']

    Token.create(
      user_id: @user.id,
      email: @user.email,
      access_token: @auth['token'],
      refresh_token: @auth['refresh_token'],
      expires_at: Time.at(@auth['expires_at']).to_datetime
    )

    imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
    imap.authenticate('XOAUTH2', @user.email, @auth['token'])
    @messages_count = imap.status('INBOX', ['MESSAGES'])['MESSAGES']
  end
end
