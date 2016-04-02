FactoryGirl.define do
  factory :href do
    url 'http://www.example.com'
    user_id 1
    newsletter_id 1
    good true
    good_host true
    good_path true
  end
end
