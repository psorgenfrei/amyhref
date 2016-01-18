namespace :mail do
  desc "Fetch new email and parse"
  task fetch: :environment do
    require 'uri'

    UrlRegex = /\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/?)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s\`!()\[\]{};:\'\".,<>?«»“”‘’]))/i

    emails = Mail.all
    puts emails.length

    emails.each_with_index do |email, index|
      puts email.subject.inspect
      puts email.from.inspect

      sender = email.from.first rescue next
      newsletter = Newsletter.find_or_create_by(:email => sender)

      all_urls = []
      body = email.body.decoded.force_encoding('utf-8').encode('UTF-8') rescue email.body.decoded.force_encoding('utf-8')

      doc = Nokogiri::HTML(body)
      links = doc.css('a')
      urls = links.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if {|href| href.empty?}
      #urls = URI.extract(body, ['http', 'https'])
      #urls = body.scan(UrlRegex)
      puts urls.inspect
      puts "~~~"

      urls.each do |url|
        href = Href.new(:url => RedirectFollower(url), :newsletter => newsletter) rescue next 

        if href.valid?
          href.save
          all_urls << href.url
        end
      end

      puts all_urls.inspect
      puts "---"
    end
  end
end
