namespace :html do
  desc "Generate a new homepage with links from the last 24 hours"
  task generate_homepage: :environment do
    hrefs = Href.where(['created_at > ?', 1.day.ago.at_beginning_of_day]).order('RAND()').limit(24)

    # TODO move the old page to a date-stamped page before creating this page
    page = Rails.root + 'public/homepage-template.html.slim'
    doc = Nokogiri::HTML(open(page))
    doc.encoding = 'utf-8'

    date = doc.at_css('h2#date')
    date.content = Time.now.strftime("%A, %b %d %Y")

    div = doc.css('div#links')[0]

    # get page title and create an embed.ly card for each href
    hrefs.each do |href|
      title = Mechanize.new.get(href.url).title rescue next
      card = "<a class='embedly-card' href='#{href.url}'>#{title}</a>"
      div.add_child(card)
    end

    File.open(Rails.root + 'app/views/home/index.html.slim', 'w:utf-8') {|f| f.write(doc.to_html) }
    restart_cmd = 'touch ' + Rails.root.to_s + '/tmp/restart.txt'
    system(restart_cmd)
  end
end