class User < ActiveRecord::Base
  has_many :tokens
  has_many :hrefs

  def bayes
    SnapshotMadeleine.new("bayes/#{self.email}") {
      Classifier::Bayes.new 'up', 'down'
    }
  end
end
