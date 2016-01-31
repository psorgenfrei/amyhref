namespace :mail do
  desc "Fetch new email and parse"
  task fetch: :environment do
    require 'uri'
    require 'open3'

    emails = Mail.find(keys: ['NOT', 'SEEN'], order: :asc)
    puts emails.length

    emails.each_with_index do |email, index|
      puts email.subject.inspect
      puts email.from.inspect

      sender = email.from.first rescue next
      newsletter = Newsletter.find_or_create_by(:email => sender)

      body = begin
        email.parts[1].body.decoded
      rescue
        Mail::Encodings.unquote_and_convert_to( email.body.decoded, 'utf-8' )
      end

      doc = Nokogiri::HTML(body)
      doc.encoding = 'utf-8'
      links = doc.css('a')
      urls = links.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if {|href| href.empty?}

      urls.each do |url|
        (href = Href.new(:url => RedirectFollower(url), :newsletter => newsletter) rescue next)

        puts 'scraping w/ phantomjs'
        stdin, stdout, stderr = Open3.popen3(Rails.root.to_s + '/./phantomjs scraper.js ' + href.url) 
        responses = stdout.read.split("\n")
        puts responses.first
        if responses.first && responses.first <> href.url
          href.url = responses.first
        end

        if href.valid?
          href.save
          href.classify_with_madeline
        end
      end
    end
  end
end
