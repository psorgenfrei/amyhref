class MailReceiver < ActionMailer::Base
  def receive(message)
    puts message.inspect
  end
end
