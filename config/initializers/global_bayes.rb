module GlobalBayes
  def self.instance
    begin
      data = File.read('bayes/all@amyhref.com')
      Marshal.load(data)
    rescue Errno::ENOENT
      ClassifierReborn::Bayes.new 'Up', 'Down'
    end
  end

  def self.save
    snapshot = Marshal.dump(classifier)
    File.open('bayes/all@amyhref.com', 'w') {|f| f.write(snapshot) }
  end
end
