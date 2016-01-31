class Href < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url, :scope => :newsletter

  belongs_to :newsletter

  before_save :unshorten_and_classify

  def unshorten_and_classify
    self.url = RedirectFollower(self.url)

    m = SnapshotMadeleine.new('bayes_data') {
      Classifier::Bayes.new 'good', 'bad'
    }

    self.update_attribute(:good, true) if m.system.classify(self.url).downcase == 'good'
  end

  def follow_simple_redirects
    RedirectFollower(self.url)
  end

  def self.follow_complex_redirects(url)
    # use something like Selenium to follow javascript redirects etc?
  end
end
