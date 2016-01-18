namespace :mail do
  desc "Fetch new email and parse"
  task fetch: :environment do
    require 'uri'

    emails = Mail.all
    puts emails.length

    emails.each_with_index do |email, index|
      puts email.subject.inspect
      puts email.from.inspect

      sender = email.from.first rescue next
      newsletter = Newsletter.find_or_create_by(:email => sender)

      all_urls = []
      body = email.body.decoded.encode('UTF-8') rescue email.body.decoded
      urls = URI.extract(body, ['http', 'https'])
      urls.each do |url|
        all_urls << Href.create(:url => url, :newsletter => newsletter).follow_simple_redirects rescue next 
      end
      puts all_urls.inspect
      puts "---"

      exit(0) #if index >= 9
    end
  end
end
