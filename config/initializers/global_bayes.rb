module GlobalBayes
  def self.instance
    if @classifier.nil?
      @classifier = begin
        data = File.read(Rails.root + 'bayes/global.dat')
        Marshal.load(data)
      rescue Errno::ENOENT, ArgumentError
        ::ClassifierReborn::Bayes.new('Up', 'Down')
      end

      if @classifier.nil?
        @classifier = ClassifierReborn::Bayes.new('Up', 'Down')
      end
    end

    @classifier
  end

  def self.snapshot
    snapshot = Marshal.dump(GlobalBayes.instance)
    File.open(Rails.root + 'bayes/global.dat', 'wb') {|f| f.write(snapshot) }
  end
end
