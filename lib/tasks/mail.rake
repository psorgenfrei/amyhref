namespace :mail do
  desc "Fetch new email and parse"
  task fetch: :environment do
    require 'uri'

    emails = Mail.all
    puts emails.length

    emails.each do |email|
      puts email.subject.inspect

      hrefs = URI.extract(email.body.decoded, ['http', 'https'])

      valid_urls = []
      hrefs.each do |url|
        valid_urls << RedirectFollower(url) rescue next
      end
      puts valid_urls.inspect
      puts "---"
      exit(0)
    end
  end
end
