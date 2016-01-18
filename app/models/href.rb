class Href < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url, :scope => :newsletter

  belongs_to :newsletter

  before_save :unshorten_url

  def domain
  end

  def protocol
  end

  def unshorten_url
    self.url = RedirectFollower(self.url)
  end

  def follow_simple_redirects
    RedirectFollower(self.url)
  end

  def self.follow_complex_redirects(url)
    # use something like Selenium to follow javascript redirects etc?
  end
end
