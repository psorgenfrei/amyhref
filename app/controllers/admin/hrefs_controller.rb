class Admin::HrefsController < ApplicationController
  before_filter :setup_madeleine

  def index
    @hrefs = Href.order('created_at DESC').paginate(:page => params[:page], :per_page => 25)
    #@hrefs.collect{ |h| h.reclassify }
  end

  def today
    @hrefs = Href.where(['created_at > ? AND created_at < ?', 1.day.ago.at_end_of_day, Time.now]).paginate(:page => params[:page], :per_page => 10)
    #@hrefs.collect{ |h| h.reclassify }

    render :action => :index
  end

  def yesterday
    @hrefs = Href.where(['created_at > ? AND created_at < ?', 1.day.ago.at_beginning_of_day, 1.day.ago.at_end_of_day]).paginate(:page => params[:page], :per_page => 10)
    #@hrefs.collect{ |h| h.reclassify }

    render :action => :index
  end

  def search
    @hrefs = Href.where(["LOWER(url) LIKE ?", '%' + params[:q].downcase + '%']).order('id DESC').paginate(:page => params[:page], :per_page => 10)

    render :action => :index
  end

  def train
    href = Href.find(params[:href_id])

    @m.system.train params[:q], href.send(params[:s]) # host or path
    @m.system.train params[:q], href.url # full url

    if params[:q] == 'up'
      if params[:s] == 'host'
        href.update_column(:good_host, true)
      elsif params[:s] == 'path'
        href.update_column(:good_path, true)
      end
    elsif params[:q] == 'down'
      if params[:s] == 'host'
        href.update_column(:good_host, false)
      elsif params[:s] == 'path'
        href.update_column(:good_path, false)
      end
    end
    set_good_or_bad(href)

    flash[:notice] = @m.system.classify(href.url)

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  protected
  def setup_madeleine
    @m = SnapshotMadeleine.new('bayes_data') {
      Classifier::Bayes.new 'up', 'down'
    }
  end

  def set_good_or_bad(href)
    href.update_column(:good, (href.good_host? && href.good_path?))
  end
end
