class Href < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url, :scope => :newsletter

  belongs_to :newsletter

  before_create :initial_classification

  require 'uri'

  def parse
    URI.parse(self.url)
  end

  def host
    self.parse.host
  end

  def path
    self.parse.path
  end

  def query_string
    self.parse.query
  end

  def classify(status)
    m = setup_madeleine
    m.system.train status.to_sym, self.url
  end

  def unshorten
    self.url = RedirectFollower(self.url)
  end

  def follow_simple_redirects
    RedirectFollower(self.url)
  end

  protected
  def setup_madeleine
    SnapshotMadeleine.new('bayes_data') {
      Classifier::Bayes.new 'up', 'down'
    }
  end

  # Callback to set the initial classification
  def initial_classification
    m = setup_madeleine
    host_status = m.system.classify(self.host).downcase
    path_status= m.system.classify(self.path).downcase

    self.good_host = true if host_status == 'up'
    self.good_path = true if path_status == 'up'

    self.good = true if self.good_host? && self.good_path?
  end
end
