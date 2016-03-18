namespace :mail do
  desc "Fetch email for each user and parse"
  task fetch_for_users: :environment do
    require 'uri'
    require 'open3'

    User.connection

    puts "Started parsing at #{Time.now}"

    # Process users starting with the ones who haven't been processed in a while
    User.order('last_processed ASC').all.each do |user|
      message_ids = []

      @imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)

      begin
        @imap.authenticate('XOAUTH2', user.email, user.tokens.last.fresh_token)
      rescue Net::IMAP::NoResponseError => e
        puts "Exception authenticating for #{user.email}"
        puts e.message.inspect
        next
      end

      # Setup the amyhref.com mailbox/label
      amyhref_folder_name = 'amyhref.com'
      if not @imap.list('', amyhref_folder_name)
        @imap.create(amyhref_folder_name)
      end

      begin
        @imap.select("[Google Mail]/All Mail")
      rescue Net::IMAP::NoResponseError
        @imap.select("[Gmail]/All Mail")
      end
      
      # First grab all the unread items labelled with amyhref
      # - allow users to drag/drop or filter messages into the folder for additional processing
      message_ids << @imap.uid_search(['X-GM-LABELS', 'amyhref.com', 'NOT', 'SEEN'])
      
      # Now search for all the recent newsletters, mark as read and archive them
      last_processed = user.last_processed || 1.week.ago
      @imap.uid_search(['SINCE', last_processed]).each do |message_id|
        email_header = @imap.uid_fetch(message_id, 'RFC822.HEADER') # equiv to BODY.PEEK
        next unless email_header

        # try a few methods to discover newsletters
        rfc822_header = email_header[0].attr['RFC822.HEADER'].downcase
        received_from = rfc822_header.scan(/received:\sfrom\s(\S*)/im).flatten.uniq
        received_by = rfc822_header.scan(/received:\sby\s(\S*)/im).flatten.uniq

        if rfc822_header.include?('list-unsubscribe') || rfc822_header.include?('list-id:') || matches_known_senders?(received_from) || matches_known_senders?(received_by)
          message_ids << message_id
          #puts @imap.uid_fetch(message_id, 'X-GM-LABELS')
        end
      end

      # Mark all relevant emails as read, archive and move them into our folder 
      message_ids = message_ids.flatten.uniq
      @imap.uid_copy(message_ids, amyhref_folder_name)
      @imap.uid_store(message_ids,'-X-GM-LABELS', :Inbox)
      @imap.uid_store(message_ids, "+FLAGS", [:Seen])

      # Fetch each email
      emails = []
      message_ids.uniq.each do |message_id|
        message = @imap.uid_fetch(message_id,'RFC822')[0].attr['RFC822']
        emails << Mail.read_from_string(message)
      end

      # Disconnect from the mail server
      @imap.expunge
      @imap.logout
      @imap.disconnect

      # Finally, process each email for links
      puts "Processing #{emails.length} email(s) for #{user.name} / #{user.email} since #{last_processed}."
      parse_emails(emails, user)
      user.update_attributes(:last_processed => Time.now)
      user.snapshot
    end
    puts "Finished at #{Time.now}"
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

          # Ensure we use the right phantomjs
          if ['foo'].pack('p').size == 8 # 64bit
            stdin, stdout, stderr = Open3.popen3("timeout 10 phantomjs scraper.js \"#{url}\" ") 
          elsif ['foo'].pack('p').size == 4 # 32bit
            stdin, stdout, stderr = Open3.popen3("timeout 10 #{Rails.root}/./phantomjs scraper.js \"#{url}\" ") 
          end
          responses = stdout.read.split("\n")
          responses.reject!{ |rsp| rsp.downcase == 'about:blank' }

          if responses && responses.last && responses.last != url
            url = responses.last
          end
          url = url.gsub(/^\s+/, '').strip

          begin
            uri = URI.parse(url) rescue next
            host = uri.host.downcase rescue next
            path = uri.path.downcase rescue next

            next if host =~ /twitter.com/ 
            next if host =~ /facebook.com/
            next if host =~ /linkedin.com/
            next if host =~ /instapaper.com/
            next if host =~ /instagram.com/

            next if host =~ /forward-to-friend\d*.com/
            next if host =~ /forwardtomyfriend\d*.com/
            next if host =~ /updatemyprofile\d*.com/
            next if host =~ /list-manage\d*.com/
            next if host =~ /campaign-archive\d*.com/
            next if host =~ /cmail\d*.com/
            next if host =~ /fanbridge.com/
            next if host =~ /typeform.com/

            next if path =~ /unsubscribe/
            next if path =~ /^\/$/

            # TODO hmm, maybe should be ful url not split on domain and path here?
            next if Href.exists?(:domain => host, :path => path, :user_id => user.id)

            href = Href.new(:url => url, :newsletter_id => newsletter.id, :user_id => user.id) rescue next

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
            next
          end
        end
      end
    rescue Exception => e
      puts e.backtrace
      puts e.message
    end
  end

  # does any entry in senders match any of the regex in known_senders?
  def matches_known_senders?(senders)
    prefixes = [
      /\S*\.getrevue\.co/,
      /\S*\.outbound-mail\.sendgrid\.net/,
      /\S*\.sendgrid.net/,
    ]

    re = Regexp.union(prefixes)
    senders.to_s.match(re)
  end
end
