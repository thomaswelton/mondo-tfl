class Card < ActiveRecord::Base
  belongs_to :user
  has_many :journeys

  def to_s
    "#{network} ending with #{last_4_digits} (exp #{expiry})"
  end
end
