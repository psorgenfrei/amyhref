class HomeController < ApplicationController
  def index
  end

  def archives
    render '/home/' + params[:archives] + '.html.slim', :layout => 'application'
  end
end
