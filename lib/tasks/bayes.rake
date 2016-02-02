namespace :bayes do
  desc "Reset the dataset to neutral"
  task reset: :environment do
    m = SnapshotMadeleine.new('bayes_data') {
      Classifier::Bayes.new 'up', 'down'
    }

    Href.all.each do |href|
      [href.url, href.host, href.path].each do |component|
        m.system.untrain :up, component rescue false
        m.system.untrain :down, component rescue false
      end
    end

    m.take_snapshot
  end

  desc "Reclassify urls from yesterday"
  task reclassify_yesterday: :environment do
    Href.where(['created_at > ? AND created_at < ?', 1.day.ago.at_beginning_of_day, 1.day.ago.at_end_of_day]).find_each.collect{ |h| h.reclassify }
  end

  desc "Reclassify urls"
  task reclassify: :environment do
    Href.where(['created_at > ?', 1.day.ago.at_beginning_of_day]).find_each.collect{ |h| h.reclassify }
  end
end
