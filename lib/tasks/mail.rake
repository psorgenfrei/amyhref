namespace :mail do
  desc "Fetch new email and parse"
  task fetch: :environment do
    require 'uri'

    emails = Mail.all
    puts emails.length

    m = SnapshotMadeleine.new('bayes_data') {
      Classifier::Bayes.new 'good', 'bad'
    }

    emails.each_with_index do |email, index|
      puts email.subject.inspect
      puts email.from.inspect

      sender = email.from.first rescue next
      newsletter = Newsletter.find_or_create_by(:email => sender)

      body = email.body.decoded.encode('UTF-8') rescue email.body.decoded

      all_urls = []
      urls = URI.extract(body, ['http', 'https'])

      urls.each do |url|
        href = Href.new(:url => RedirectFollower(url), :newsletter => newsletter) rescue next 

        if href.valid?
          href.save
          m.system.train_bad(href.url)
          all_urls << href.url
        end
      end
      puts all_urls.inspect
      puts "---"

      if index >= 10
        m.take_snapshot
      end
    end
  end
end
