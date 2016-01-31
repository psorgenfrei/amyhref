namespace :html do
  desc "Generate a new homepage with links from the last 24 hours"
  task :generate_homepage do
    hrefs = Href.where("created_at > current_timestamp - interval '1 day'").order('RANDOM()').limit(24)

    # TODO move the old page to a date-stamped page before creating this page
    page = Rails.root + '/public/homepage-template.html.slim'
    doc = Nokogiri::HTML(open(page))
    doc.encoding = 'utf-8'

    div = doc.css('div#links')

    hrefs.each do |href|
      # get page title and create an embed.ly card
      title = Mechanize.new.get(href.url).title rescue next
      card = "<a class='embedly-card' href='#{href.url}'>#{title}</a><script async src='//cdn.embedly.com/widgets/platform.js' charset='UTF-8'></script>"

      # add to page
      div.add_child(card)
    end

    File.open(Rails.root + 'app/views/index.html.slim, 'w:utf-8') {|f| f.write(doc.to_html) }
  end
end
