class MailReceiver < ActiveRecord::Base
  #Mailman::Rails.receive do
  #  default do
  #    puts message.inspect
  #    logger.debug message.inspect
  #    Post.create(JSON.parse(message.body))
  #    exit
  #  end
  #end
  def receive(message, params)
    puts "2"
  end
end
