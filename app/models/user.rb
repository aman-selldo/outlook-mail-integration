class User < ApplicationRecord
  validates :email, presence: true, uniqueness:true
  validates :microsoft_uid, presence: true, uniqueness: true
end