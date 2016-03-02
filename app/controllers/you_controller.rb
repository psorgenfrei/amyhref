class YouController < ApplicationController
  before_filter :require_user

  def index
    #@hrefs = current_user.hrefs.group('domain, DATE(created_at)').where(:good => true).order('id DESC, rating ASC').page(params[:page]).per_page(5)
    @hrefs = current_user.hrefs.group(:newsletter_id).where(:good => true).order('id DESC, rating ASC').page(params[:page]).per_page(5)
  end
end
