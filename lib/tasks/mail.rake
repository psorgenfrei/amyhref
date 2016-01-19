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
      #body = email.body.decoded.force_encoding('utf-8').encode('UTF-8') rescue email.body.decoded.force_encoding('utf-8')
      body = begin
        email.parts[1].body.decoded
      rescue
        #puts "oi"
        #puts email.parts.first.content_transfer_encoding.to_s
        #puts email.body.decoded
        #puts 'aaa'
        #puts email.body.decoded.unpack("M*")
        #puts "bbb"
        #puts email.body.decoded.force_encoding("ISO-8859-1").encode("UTF-8")
        #puts "ccc"
        #puts Mail::Encodings.unquote_and_convert_to( email.body.decoded, 'utf-8' )
        Mail::Encodings.unquote_and_convert_to( email.body.decoded, 'utf-8' )
      end

      doc = Nokogiri::HTML(body)
      doc.encoding = 'utf-8'
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
