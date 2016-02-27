class YouController < ApplicationController
  before_filter :require_user

  def index
    imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
puts current_user.tokens.last.access_token
puts "----2"
    imap.authenticate('XOAUTH2', current_user.email, current_user.tokens.last.access_token)
    @inbox_messages_count = imap.status('INBOX', ['MESSAGES'])['MESSAGES']
    @all_messages_count = imap.status("[Google Mail]/All Mail", ['MESSAGES'])['MESSAGES']
  end
end
