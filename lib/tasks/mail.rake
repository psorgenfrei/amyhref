require 'byebug'

namespace :mail do
  desc "Fetch new email and parse"
  task fetch: :environment do
    require 'uri'
    require 'open3'

    emails = Mail.find(keys: ['NOT', 'SEEN'], count: 5, order: :asc)
    puts emails.length

    begin
      emails.each_with_index do |email, index|
        puts email.subject.inspect
        puts email.from.inspect

        sender = email.from.first rescue next
        newsletter = Newsletter.find_or_create_by(:email => sender)

        body = begin
          #email.body.decoded
          email.parts[1].body.decoded
        rescue
          Mail::Encodings.unquote_and_convert_to( email.body.decoded, 'utf-8' )
        end

        # handle Quoted Printable crap with an axe
        body = body.unpack('M')[0]
        body = body.gsub(/=\n/, '')
        body = body.gsub(/=3D/, '=')

        doc = Nokogiri::HTML(body)
        doc.encoding = 'utf-8'
        links = doc.css('a')
        urls = links.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if {|href| href.empty?}

        urls.each do |url|
          puts 'scraping w/ phantomjs'
          url = url.gsub(/^\s+/, '').strip
          puts url

          stdin, stdout, stderr = Open3.popen3("#{Rails.root}/./phantomjs scraper.js \"#{url}\" ") 
          responses = stdout.read.split("\n")
          responses.reject!{ |rsp| rsp.downcase == 'about:blank' }

          if responses && responses.last && responses.last != url
            url = responses.last
          end
          url = url.gsub(/^\s+/, '').strip

          puts url
          puts "^^^ done"

          begin
            #byebug
            href = Href.new(:url => url, :newsletter_id => newsletter.id) rescue next
            host = href.host.downcase rescue next

            next if host =~ /twitter.com/ 
            next if host =~ /facebook.com/
            next if host =~ /linkedin.com/
            next if host =~ /instapaper.com/
            next if host =~ /forward-to-friend\d*.com/
            next if host =~ /list-manage\d*.com/
            next if host =~ /campaign-archive\d*.com/

            if href.valid?
              unless ActiveRecord::Base.connected?
                ActiveRecord::Base.connection.reconnect!
              end

              href.save
              puts "Saved #{href.url.inspect}"
            else
              puts "Skipping invalid url: #{href.url}"
            end
          rescue SystemStackError
            puts $!
            puts caller[0..500]
          end
        end
      end
    rescue Exception => e
      puts e.backtrace
      puts e.message
    end
  end
end
