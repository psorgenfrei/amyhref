class User < ActiveRecord::Base
  has_many :tokens
  has_many :hrefs

  validates_uniqueness_of :email

  def bayes
    begin
      data = File.read("bayes/#{self.email}")
      Marshal.load(data)
    rescue Errno::ENOENT
      ClassifierReborn::Bayes.new 'Up', 'Down'
    end
  end

  def snapshot
    snapshot = Marshal.dump(@m)
    File.open('bayes/' + self.email, 'w') {|f| f.write(snapshot) }
  end
end
