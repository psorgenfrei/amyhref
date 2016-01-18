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

      all_urls = []
      body = email.body.decoded.encode('UTF-8') rescue email.body.decoded
      urls = URI.extract(body, ['http', 'https'])
      urls.each do |url|
        href = Href.create(:url => url, :newsletter => newsletter).follow_simple_redirects rescue next 
        m.system.train_bad(href.url)
        all_urls << href.url
      end
      puts all_urls.inspect
      puts "---"

      if index >= 9
        m.take_snapshot
        exit(0)
      end
    end
  end
end
