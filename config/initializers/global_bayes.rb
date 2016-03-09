module GlobalBayes
  def self.instance
    if @classifier.nil?
      @classifier = begin
        data = File.read("bayes/global.dat")
        Marshal.load(data)
      rescue Errno::ENOENT
        ClassifierReborn::Bayes.new('Up', 'Down')
      end

      if @classifier.nil?
        @classifier = ClassifierReborn::Bayes.new('Up', 'Down')
      end
    end

    @classifier
  end

  def self.snapshot
    snapshot = Marshal.dump(GlobalBayes.instance)
    File.open('bayes/global.dat', 'wb') {|f| f.write(snapshot) }
  end
end
