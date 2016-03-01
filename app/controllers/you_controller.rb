class YouController < ApplicationController
  before_filter :require_user

  def index
    @imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
    @imap.authenticate('XOAUTH2', current_user.email, current_user.tokens.last.fresh_token)

    amyhref_folder_name = 'amyhref.com'

    # Setup the amyhref.com label
    if not @imap.list('', amyhref_folder_name)
      @imap.create(amyhref_folder_name)
    end

    #begin
    #  @imap.create(amyhref_folder_name)
    #rescue Net::IMAP::NoResponseError
    #  # folder exists
    #end

    @inbox_messages_count = 0 #@imap.status('INBOX', ['MESSAGES'])['MESSAGES']
    @all_messages_count = 0 #@imap.status("[Google Mail]/All Mail", ['MESSAGES'])['MESSAGES']

    #@imap.examine("[Google Mail]/All Mail") # read-only
    #@imap.uid_search(["NOT", "DELETED"]).each_with_index do |message_id, index|
    #  next if index >= 50
    #  envelope = @imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
    #  "#{envelope.from[0].name}: \t#{envelope.subject}"
    #end

    @messages = []
    message_ids = []

    # TODO this might be [Gmail] rather than [Google Mail]
    @imap.select("[Google Mail]/All Mail")
    @imap.uid_search(['SINCE', 2.weeks.ago]).each do |message_id|
      #envelope = @imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
      #@messages << "#{envelope.from[0].name}: \t#{envelope.subject}"

      email_header = @imap.uid_fetch(message_id, 'RFC822.HEADER') # equiv to BODY.PEEK

      if email_header[0].attr['RFC822.HEADER'].downcase.include? 'list-unsubscribe'
        #puts email_header[0].attr['RFC822.HEADER'].inspect
        #puts "--"

        envelope = @imap.uid_fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
        @messages << "#{envelope.from[0].name}: \t#{envelope.subject}"

# problem is I'm starting in All Mail and marking as deleted etc,
# but i should store all the message_ids and then delete them from the inbox
# need to remove the Inbox label, not move it to all mail

        @imap.uid_copy(message_id, amyhref_folder_name)
        @imap.uid_store(message_id, "+FLAGS", [:Seen])
        #@imap.uid_store(message_id, "+FLAGS", [:Deleted])
        message_ids << message_id

        #puts @imap.uid_fetch(message_id, 'X-GM-LABELS')
        @imap.uid_store(message_id,'-X-GM-LABELS', :Inbox)
      end
    end

#    @imap.select("Inbox")
#    message_ids.each do |message_id|
#puts message_id
#puts "~~~"
#puts @imap.uid_fetch(message_id, "BODY[HEADER.FIELDS (SUBJECT)]").inspect
#    end
#    @imap.uid_search(message_ids).each do |message_id|
#puts 'here'
#puts message_id
#      @imap.uid_store(message_id, "+FLAGS", [:Deleted])
#    end

    @imap.expunge

    # using Mail to parse responses
    #body = @imap.fetch(message_id,'BODY[TEXT]')[0].attr['BODY[TEXT]']
    #msg = @imap.fetch(-1,'RFC822')[0].attr['RFC822']
    #mail = Mail.read_from_string msg

    @imap.logout
    @imap.disconnect
  end
end
