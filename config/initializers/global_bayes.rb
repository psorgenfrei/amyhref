module GlobalBayes
  def self.instance
    classifier = begin
      data = File.read("bayes/all@amyhref.com")
      Marshal.load(data)
    rescue Errno::ENOENT
      ClassifierReborn::Bayes.new 'Up', 'Down'
    end

    if classifier.nil?
      classifier = ClassifierReborn::Bayes.new( 'Up', 'Down')
    end
    classifier
  end

  def self.save
    snapshot = Marshal.dump(classifier)
    File.open('bayes/all@amyhref.com', 'w') {|f| f.write(snapshot) }
  end
end
