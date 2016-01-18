class Newsletter < ActiveRecord::Base
  validates_presence_of :email
  validates_uniqueness_of :email

  has_many :hrefs
end
