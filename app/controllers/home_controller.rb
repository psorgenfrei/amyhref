class HomeController < ApplicationController
  def index
    @hrefs = Href.where(good: true, good_host: true, good_path: true).group('DATE(created_at), newsletter_id').order('created_at DESC, rating ASC').page(params[:page])
  end

  def archives
    render '/home/' + params[:archives] + '.html.slim', :layout => 'application'
  end
end
