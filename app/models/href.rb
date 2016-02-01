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
      m.system.train_good_host(self.host)
      m.system.train_good_path(self.path)

      self.update_column(:good, true)
      self.update_column(:good_host, true)
      self.update_column(:good_path, true)
    else
      m.system.train_bad(self.url)
      m.system.train_bad_host(self.host)
      m.system.train_bad_path(self.path)

      self.update_column(:good, false)
      self.update_column(:good_host, false)
      self.update_column(:good_path, false)
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
      Classifier::Bayes.new 'good', 'good_host', 'good_path', 'bad', 'bad_host', 'bad_path'
    }
  end
end
