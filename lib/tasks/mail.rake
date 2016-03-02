#require 'byebug'

namespace :mail do
  desc "Fetch email for each user and parse"
  task fetch_for_users: :environment do
    require 'uri'
    require 'open3'

    User.connection
    User.all.each do |user|
      @imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
      @imap.authenticate('XOAUTH2', user.email, user.tokens.last.fresh_token)

      # Setup the amyhref.com mailbox/label
      amyhref_folder_name = 'amyhref.com'
      if not @imap.list('', amyhref_folder_name)
        @imap.create(amyhref_folder_name)
      end

      @imap.select("[Google Mail]/All Mail")

      
      # Label all newsletters, mark as read and remove from inbox
      message_ids = []
      last_processed = user.last_processed || 2.weeks.ago

      puts "Processing #{user.name} from #{last_processed}."
      @imap.uid_search(['SINCE', last_processed]).each do |message_id|
        #envelope = @imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
        #@messages << "#{envelope.from[0].name}: \t#{envelope.subject}"

        email_header = @imap.uid_fetch(message_id, 'RFC822.HEADER') # equiv to BODY.PEEK

        if email_header[0].attr['RFC822.HEADER'].downcase.include? 'list-unsubscribe'
          message_ids << message_id

          @imap.uid_copy(message_id, amyhref_folder_name)
          @imap.uid_store(message_id, "+FLAGS", [:Seen])

          #puts @imap.uid_fetch(message_id, 'X-GM-LABELS')
          @imap.uid_store(message_id,'-X-GM-LABELS', :Inbox)
        end
      end

      # Parse each email for links
      emails = []
      message_ids.each do |message_id|
        message = @imap.uid_fetch(message_id,'RFC822')[0].attr['RFC822']
        emails << Mail.read_from_string(message)
      end


      @imap.expunge
      @imap.logout
      @imap.disconnect

# TODO
# will just keep reprocessing emails that are read and archived?
# or will last_processed take care of that?
# signin with Amy to create her account also
      parse_emails(emails, user)
      user.update_attributes(:last_processed => Time.now)
    end
  end

  desc "Fetch Amy's new email and parse"
  task fetch: :environment do
    require 'uri'
    require 'open3'

    user = User.where(:email => 'amyhref@gmail.com').first
    emails = Mail.find(keys: ['NOT', 'SEEN'], count: 25, order: :asc)
    parse_emails(emails, user)
  end

  private
  def parse_emails(emails, user)
    puts "Processing #{emails.length} email(s) for #{user.name}"

    begin
      emails.each do |email|
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
          next if url =~ /unsubscribe/ 

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

          puts responses.inspect
          puts url
          puts "^^^ done"

          begin
            #byebug
            href = Href.new(:url => url, :newsletter_id => newsletter.id, :user_id => user.id) rescue next
            host = href.host.downcase rescue next

            next if host =~ /twitter.com/ 
            next if host =~ /facebook.com/
            next if host =~ /linkedin.com/
            next if host =~ /instapaper.com/
            next if host =~ /forward-to-friend\d*.com/
            next if host =~ /forwardtomyfriend\d*.com/
            next if host =~ /updatemyprofile\d*.com/
            next if host =~ /list-manage\d*.com/
            next if host =~ /campaign-archive\d*.com/
            next if host =~ /fanbridge.com/
            next if host =~ /typeform.com/

            if href.valid?
              unless ActiveRecord::Base.connected?
                ActiveRecord::Base.connection.reconnect!
              end

              href.save!
              puts "Saved #{href.url.inspect}"
            else
              puts "Skipping invalid/duplicate url: #{href.url}"
            end
          rescue SystemStackError
            puts $!
            puts caller[0..500]
          end
          sleep(5)
        end
      end
    rescue Exception => e
      puts e.backtrace
      puts e.message
    end
  end
end
