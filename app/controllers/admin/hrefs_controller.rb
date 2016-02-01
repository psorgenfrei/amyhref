class Admin::HrefsController < ApplicationController
  before_filter :setup_madeleine

  def index
    @hrefs = Href.order('created_at DESC').paginate(:page => params[:page], :per_page => 25)
  end

  def train
    href = Href.find(params[:href_id])

    @m.system.train params[:q].to_sym, href.url
    @m.system.train params[:q].to_sym, href.send(params[:s].to_sym)

    flash[:notice] = @m.system.classify(href.url)
    #flash[:notice] = @m.system.classifications(href.url).sort_by { |a| -a[1] }.to_s

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
