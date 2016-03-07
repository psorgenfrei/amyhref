class Href < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url, :scope => [:newsletter, :user]

  belongs_to :user
  belongs_to :newsletter

  before_save :set_domain
  before_save :set_path

  after_create :initial_classification

  require 'uri'

  def parse
    URI.parse(self.url)
  end

  def host
    self.parse.host
  end

  def parse_path
    self.parse.path
  end

  def query_string
    self.parse.query
  end

  def unshorten
    self.url = RedirectFollower(self.url)
  end

  def follow_simple_redirects
    RedirectFollower(self.url)
  end

  def reclassify
    initial_classification
    self.save
  end

  def train(key, value)
    @m = self.user.bayes
    @m.system.train(key, value)
    self.reclassify
    @m.take_snapshot
    @m.system.classifications(value)
  end

  protected
  def set_domain
    self.domain = self.host
  end

  def set_path
    self.path = self.parse.path
  end

  # Callback to set the initial classification
  # - use a timeout because sometimes we get stack level errors
  def initial_classification
    self.url.strip!

    @m = self.user.bayes

    path_status= @m.system.classify(self.path).downcase rescue 'down'
    host_status = @m.system.classify(self.host).downcase rescue 'down'
    url_status = @m.system.classify(self.url).downcase rescue 'down'
puts path_status
puts host_status
puts url_status

    self.good_host = true if host_status == 'up'
    self.good_path = true if path_status == 'up'

    self.rating = @m.system.classifications(self.url).sort{ |k,v| v[0].to_i }.reverse.first[1] rescue false
puts self.rating
puts "---"

    if url_status == 'up' && self.good_host? && self.good_path?
      self.good = true
    else
      self.good = false
    end
    self.save
  end
end
