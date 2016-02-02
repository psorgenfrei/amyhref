class Admin::HrefsController < ApplicationController
  before_filter :setup_madeleine

  def index
    @hrefs = Href.order('created_at DESC').paginate(:page => params[:page], :per_page => 25)
    @hrefs.collect{ |h| h.reclassify }
  end

  def yesterday
    @hrefs = Href.where(['created_at > ? AND created_at < ?', 1.day.ago.at_beginning_of_day, 1.day.ago.at_end_of_day]).paginate(:page => params[:page], :per_page => 10)
    @hrefs.collect{ |h| h.reclassify }

    render :action => :index
  end

  def train
    href = Href.find(params[:href_id])

    @m.system.train params[:q].to_sym, href.url
    @m.system.train params[:q].to_sym, href.send(params[:s].to_sym)

    flash[:notice] = @m.system.classify(href.url)

    @m.take_snapshot

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

    href.reclassify

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def untrain
    href = Href.find(params[:href_id])

    [href.url, href.host, href.path].each do |component|
      @m.system.untrain 'up', component rescue false
      @m.system.untrain 'down', component rescue false
    end

    href.update_column(:good, false)
    href.update_column(:good_host, false)
    href.update_column(:good_path, false)

    flash[:notice] = 'Untrained'

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
