class YouController < ApplicationController
  before_filter :require_user
  before_filter :fetch_newsletters

  def index
    @hrefs = current_user.hrefs.where(good: true). order('created_at DESC, rating ASC').paginate(:page => params[:page], :per_page => 5)
  end

  def newsletters
    @newsletter = Newsletter.where(id: params[:newsletter_id]).first
    @hrefs = current_user.hrefs.where(good: true, newsletter_id: @newsletter.id). order('created_at DESC, rating ASC').paginate(:page => params[:page], :per_page => 5)

    render action: :index
  end

  def search
    query = '%' + params[:q].downcase + '%'
    @hrefs = current_user.hrefs.joins(:newsletter).where(good: true).where(['LOWER(hrefs.url) LIKE ? OR LOWER(newsletters.email) = ?', query, query]).order('created_at DESC, rating ASC').paginate(:page => params[:page], :per_page => 5)

    render action: :index
  end

  protected
  def fetch_newsletters
    newsletter_ids = current_user.hrefs.select(:newsletter_id).where(good: true).group(:newsletter_id)
    @newsletters = Newsletter.where(id: newsletter_ids).order('id DESC')
  end
end
