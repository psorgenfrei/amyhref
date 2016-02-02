class Href < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url, :scope => :newsletter

  belongs_to :newsletter

  before_create :initial_classification

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

  def reclassify
    puts self.url
    initial_classification
    self.save
  end

  protected
  def setup_madeleine
    SnapshotMadeleine.new('bayes_data') {
      Classifier::Bayes.new 'up', 'down'
    }
  end

  # Callback to set the initial classification
  # - use a timeout because sometimes we get stack level errors
  def initial_classification
    begin
      Timeout::timeout(10) do
        m = setup_madeleine

        url_status = m.system.classify(self.url).downcase rescue 'down'
        host_status = m.system.classify(self.host).downcase rescue 'down'
        path_status= m.system.classify(self.path).downcase rescue 'down'

        self.good_host = true if host_status == 'up'
        self.good_path = true if path_status == 'up'

        if (self.good_host? && self.good_path?) || url_status == 'up'
          self.good = true
        else
          self.good = false
        end
      end
    rescue Timeout::Error
      self.destroy
      # delete this Href model for safety??
    end
  end
end
