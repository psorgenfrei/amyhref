namespace :mail do
  desc "Fetch new email and parse"
  task fetch: :environment do
    require 'uri'

    emails = Mail.find(keys: ['NOT', 'SEEN'], order: :asc)
    puts emails.length

    emails.each_with_index do |email, index|
      puts email.subject.inspect
      puts email.from.inspect

      sender = email.from.first rescue next
      newsletter = Newsletter.find_or_create_by(:email => sender)

      all_urls = []
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

        if href.valid?
          href.save
          all_urls << href.url
        end
      end
    end
  end
end
