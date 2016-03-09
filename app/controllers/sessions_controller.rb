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


      begin
        FileUtils.cp(Rails.root + "bayes/global.dat", Rails.root + "bayes/#{@user.email}")
      rescue Errno::EEXIST, Errno::ENOENT
        puts "File exists, skipping default bayes setup"
      end
    end

    @auth = request.env['omniauth.auth']['credentials']

    if @user.tokens.any?
      @user.tokens.last.update_attributes(
        access_token: @auth['token'],
        expires_at: Time.at(@auth['expires_at']).to_datetime
      )
    else
      Token.create(
        user_id: @user.id,
        email: @user.email,
        access_token: @auth['token'],
        refresh_token: @auth['refresh_token'],
        expires_at: Time.at(@auth['expires_at']).to_datetime
      )
    end

    session[:current_user] = @user.id
    redirect_to '/you'
  end

  def destroy
    session.delete(:current_user)
    redirect_to root_path and return
  end
end
