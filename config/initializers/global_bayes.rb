module GlobalBayes
  def self.instance
    SnapshotMadeleine.new('bayes/all@amyhref.com') {
      Classifier::Bayes.new 'up', 'down'
    }.system
  end
end
