class Href < ActiveRecord::Base
  #validates_presence_of :url
  validates_uniqueness_of :url, :scope => :newsletter

  belongs_to :newsletter

  before_save :set_domain
  after_create :initial_classification

  require 'uri'

  def parse
    URI.parse(self.url) rescue self.destroy
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
    @m ||= setup_madeleine
    @m.system.train(key.to_sym, value)
    self.reclassify
    @m.take_snapshot
    @m.system.classifications(value)
  end

  protected
  def set_domain
    self.domain = self.host
  end

  def setup_madeleine
    SnapshotMadeleine.new('bayes_data') {
      Classifier::Bayes.new 'up', 'down'
    }
  end

  # Callback to set the initial classification
  # - use a timeout because sometimes we get stack level errors
  def initial_classification
    self.url.strip!

    @m ||= setup_madeleine

    path_status= @m.system.classify(self.path).downcase rescue 'down'
    host_status = @m.system.classify(self.host).downcase rescue 'down'

    self.good_host = true if host_status == 'up'
    self.good_path = true if path_status == 'up'

    if self.good_host? && self.good_path?
      self.good = true
    else
      self.good = false
    end
    self.save
  end
end
