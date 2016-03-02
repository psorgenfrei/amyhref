class YouController < ApplicationController
  before_filter :require_user

  def index
    @hrefs = current_user.hrefs.group('newsletter_id, DATE(created_at)').where(:good => true).order('id DESC, rating ASC').page(params[:page])
  end
end
