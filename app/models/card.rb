class Card < ActiveRecord::Base
  belongs_to :user

  def to_s
    "#{network} ending with #{last_4_digits} (exp #{expiry})"
  end
end
