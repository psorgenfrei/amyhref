class Newsletter < ActiveRecord::Base
  validates_presence_of :email

  has_many :hrefs
end
