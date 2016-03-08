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
    @m.system.train(key.to_sym, value)
    self.reclassify

    self.user.snapshot

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

    # per-user ranking
    bayes = self.user.bayes
    path_status= bayes.classify(self.path).downcase rescue 'down'
    host_status =bayes.classify(self.host).downcase rescue 'down'
    url_status = bayes.classify(self.url).downcase rescue 'down'

    # global ranking
    GlobalBayes.instance.classify(self.path).downcase rescue 'down'
    GlobalBayes.instance.classify(self.host).downcase rescue 'down'
    GlobalBayes.instance.classify(self.url).downcase rescue 'down'

    self.good_host = true if host_status == 'up'
    self.good_path = true if path_status == 'up'

    self.rating = bayes.classifications(self.url).sort{ |k,v| v[0].to_i }.reverse.first[1].to_f rescue false
    self.rating = false if self.rating.to_s == Infinity

    if url_status == 'up' && self.good_host? && self.good_path?
      self.good = true
    else
      self.good = false
    end
    self.save
  end
end
