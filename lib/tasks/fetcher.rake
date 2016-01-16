namespace :fetcher do
  desc "Get new mail and parse it for links"
  task :fetch_mail => :environment do
    begin
      Lockfile.new('cron_mail_fetcher.lock', :retries => 0) do
        config = YAML.load_file("#{Rails.root}/config/mail.yml")
        config = config[Rails.env].to_options

        fetcher = Fetcher.create({:receiver => MailReceiver}.merge(config))
        fetcher.fetch
      end
    rescue Lockfile::MaxTriesLockError => e
      puts "Another fetcher is already running. Exiting."
    end
  end
end
