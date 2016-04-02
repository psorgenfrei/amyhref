class HomeController < ApplicationController
  def index
    user = User.where(email: 'amyhref@gmail.com').first
    @hrefs = Href.where(user_id: user.id, good: true, good_host: true, good_path: true).group('DATE(created_at), newsletter_id').order('created_at DESC, rating ASC').limit(12)
  end
end
