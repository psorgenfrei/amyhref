class HomeController < ApplicationController
  def index
    user = User.where(email: 'amyhref@gmail.com').first || User.last
    @hrefs = user.hrefs.where(:good => true). order('created_at DESC, rating ASC').page(params[:page])
  end

  def archives
    render '/home/' + params[:archives] + '.html.slim', :layout => 'application'
  end
end
