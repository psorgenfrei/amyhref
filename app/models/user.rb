class User < ActiveRecord::Base
  has_many :tokens, -> { order('created_at DESC') }
  has_many :hrefs, -> {order('created_at DESC') }
end
