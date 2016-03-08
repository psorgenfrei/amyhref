class YouController < ApplicationController
  before_filter :require_user

  def index
    #@hrefs = current_user.hrefs.group('domain, DATE(created_at)').where(:good => true).order('id DESC, rating ASC').page(params[:page]).per_page(5)
    #@hrefs = current_user.hrefs.group(:newsletter_id).where(:good => true).order('id DESC, rating ASC').page(params[:page]).per_page(5)
    #@hrefs = current_user.hrefs.select('id, url, rating, newsletter_id, created_at, DATE(created_at) AS date').where(:good => true).group('newsletter_id, date').order('date DESC, rating ASC').page(params[:page])
    @hrefs = current_user.hrefs.where(:good => true). order('created_at DESC, rating ASC').page(params[:page])
  end
end
