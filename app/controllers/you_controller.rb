class YouController < ApplicationController
  before_filter :require_user

  def index
    @imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
    @imap.authenticate('XOAUTH2', current_user.email, current_user.tokens.last.fresh_token)

    @inbox_messages_count = @imap.status('INBOX', ['MESSAGES'])['MESSAGES']
    @all_messages_count = @imap.status("[Google Mail]/All Mail", ['MESSAGES'])['MESSAGES']

    #@imap.examine("[Google Mail]/All Mail")
    #@imap.uid_search(["NOT", "DELETED"]).each_with_index do |message_id, index|
    #  next if index >= 50
    #  envelope = @imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
    #  "#{envelope.from[0].name}: \t#{envelope.subject}"
    #end

    @messages = []
    @imap.examine("[Google Mail]/All Mail")
    @imap.search(['SINCE', 1.week.ago]).each do |message_id|
      #envelope = @imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
      #@messages << "#{envelope.from[0].name}: \t#{envelope.subject}"

      email_header = @imap.fetch(message_id, 'RFC822.HEADER')

      if email_header[0].attr['RFC822.HEADER'].downcase.include? 'list-unsubscribe'
        envelope = @imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
        @messages << "#{envelope.from[0].name}: \t#{envelope.subject}"
      end
    end

    # using Mail to parse responses
    #body = @imap.fetch(message_id,'BODY[TEXT]')[0].attr['BODY[TEXT]']
    #msg = @imap.fetch(-1,'RFC822')[0].attr['RFC822']
    #mail = Mail.read_from_string msg

    @imap.logout
    @imap.disconnect
  end
end
