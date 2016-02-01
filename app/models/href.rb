class Href < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url, :scope => :newsletter

  belongs_to :newsletter

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

  def classify_with_madeleine 
    m = setup_madeleine
    self.classify(m.system.classify(self.url))
  end

  def classify(status)
    m = setup_madeleine

    if status.downcase == 'good'
      m.system.train_good(self.url)
      self.update_column(:good, true)
    else
      m.system.train_bad(self.url)
      self.update_column(:good, false)
    end
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
      Classifier::Bayes.new 'good', 'bad'
    }
  end
end
