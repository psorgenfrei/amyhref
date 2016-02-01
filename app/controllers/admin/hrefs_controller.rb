class Admin::HrefsController < ApplicationController
  before_filter :setup_madeleine

  def index
    @hrefs = Href.order('created_at DESC').paginate(:page => params[:page], :per_page => 25)
  end

  def train
    href = Href.find(params[:href_id])

    if params[:q] == 'good_host'
      flash[:notice] = 'Upvoted host'
      href.update_column(:good_host, true)
      @m.system.train_good_host(href.parse.host)
    elsif params[:q] == 'bad_host'
      flash[:notice] = 'Downvoted host'
      href.update_column(:good_host, false)
      @m.system.train_bad_host(href.parse.host)
    elsif params[:q] == 'good_path'
      flash[:notice] = 'Upvoted path'
      href.update_column(:good_path, true)
      @m.system.train_good_path(href.parse.path)
    elsif params[:q] == 'bad_path'
      flash[:notice] = 'Downvoted path'
      href.update_column(:good_path, false)
      @m.system.train_bad_path(href.parse.path)
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def train_good
    href = Href.find(params[:href_id])
    href.update_column(:good, true)

    @m.system.train_good(href.url)

    flash[:notice] = 'Upvoted'

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def train_bad
    href = Href.find(params[:href_id])
    href.update_column(:good, false)

    @m.system.train_bad(href.url)

    flash[:notice] = 'Downvoted'

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  protected
  def setup_madeleine
    @m = SnapshotMadeleine.new('bayes_data') {
      Classifier::Bayes.new 'good', 'good_host', 'good_path', 'bad', 'bad_host', 'bad_path'
    }
  end
end
