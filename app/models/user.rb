# encoding: utf-8

class User < ActiveRecord::Base
  has_many :tokens
  has_many :hrefs

  validates_uniqueness_of :email

  attr_accessor :classifier

  def bayes
    if @classifier.nil?
      @classifier = begin
        data = File.read("bayes/#{self.email}.dat")
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

  def snapshot
    snapshot = Marshal.dump(self.bayes)
    File.open('bayes/' + self.email + '.dat', 'wb') {|f| f.write(snapshot) }
  end
end
