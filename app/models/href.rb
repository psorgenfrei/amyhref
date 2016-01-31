class Href < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url, :scope => :newsletter

  belongs_to :newsletter

  def classify_with_madeleine 
    m = SnapshotMadeleine.new('bayes_data') {
      Classifier::Bayes.new 'good', 'bad'
    }

    self.classify(m.system.classify(self.url))
  end

  def classify(status)
    if status.downcase == 'good'
      self.update_column(:good, true)
    else
      self.update_column(:good, false)
    end
  end

  def unshorten
    self.url = RedirectFollower(self.url)
  end

  def follow_simple_redirects
    RedirectFollower(self.url)
  end

  def self.follow_complex_redirects(url)
    # use something like Selenium to follow javascript redirects etc?
  end
end
