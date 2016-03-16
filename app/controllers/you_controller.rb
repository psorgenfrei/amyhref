class YouController < ApplicationController
  before_filter :require_user
  before_filter :fetch_newsletters

  def index
    @hrefs = current_user.hrefs.where(good: true). order('created_at DESC, rating ASC').paginate(:page => params[:page], :per_page => 5)

    if request.xhr?
      render :partial => 'shared/hrefs'
    else
      render
    end
  end

  def newsletter
    @newsletter = Newsletter.where(id: params[:newsletter_id]).first
    @hrefs = current_user.hrefs.where(good: true, newsletter_id: @newsletter.id).order('created_at DESC, rating ASC').paginate(:page => params[:page], :per_page => 5)

    if request.xhr?
      render :partial => 'shared/hrefs'
    else
      render action: :index
    end
  end

  def search
    query = '%' + params[:q].downcase + '%'
    @hrefs = current_user.hrefs.joins(:newsletter).where(good: true).where(['LOWER(hrefs.url) LIKE ? OR LOWER(newsletters.email) = ?', query, query]).order('created_at DESC, rating ASC').paginate(:page => params[:page], :per_page => 5)

    if request.xhr?
      render :partial => 'shared/href', :collection => @hrefs
    else
      render action: :index
    end
  end

  def spam
    @hrefs = current_user.hrefs.where(good: false).order('created_at DESC, rating ASC').paginate(:page => params[:page], :per_page => 5)

    if request.xhr?
      render :partial => 'shared/href', :collection => @hrefs
    else
      render action: :index
    end
  end

  def up
    @href = Href.find(params[:id])
    render # do this asap

    @href.train(:Up, @href.url)
    @href.train(:Up, @href.domain)
    @href.train(:Up, @href.path)

    @href.update_attributes(good: true, good_host: true, good_path: true)

    current_user.snapshot if rand(3) == 0
  end

  def down
    @href = Href.find(params[:id])
    render # do this asap

    @href.train(:Down, @href.url)
    @href.train(:Down, @href.domain)
    @href.train(:Down, @href.path)

    @href.update_attributes(good: false, good_host: false, good_path: false)

    current_user.snapshot if rand(3) == 0
  end

  protected
  def fetch_newsletters
    newsletter_ids = current_user.hrefs.select(:newsletter_id).where(good: true).group(:newsletter_id)
    @newsletters = Newsletter.where(id: newsletter_ids).order('id DESC')
  end
end
