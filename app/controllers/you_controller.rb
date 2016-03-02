class YouController < ApplicationController
  before_filter :require_user

  def index
    @hrefs = current_user.hrefs.where(['created_at > ? AND created_at < ?', Date.today.at_beginning_of_day, Date.today.at_end_of_day]).group(:newsletter_id).where(:good => true).order('id DESC')
  end
end
