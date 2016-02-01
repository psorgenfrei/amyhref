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
end
