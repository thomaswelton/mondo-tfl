class Journey < ActiveRecord::Base
  belongs_to :user
  belongs_to :card

  scope :matched, -> { where('mondo_transaction_id IS NOT NULL') }
  scope :unmatched, -> { where(mondo_transaction_id: nil) }

  def fare
    Money.new(self[:fare], :gbp)
  end

  def self.in_peak_hour
    # mod 390 = 0630
    # mod 570 = 0930
    where('tapped_in_mod between 390 AND 570 AND EXTRACT(DOW FROM journeys.date) >= 1 AND EXTRACT(DOW FROM journeys.date) <= 5')
  end

  def self.last_month
    end_of_last_month = Date.today.at_beginning_of_month - 1
    where('date between ? AND ?', end_of_last_month.at_beginning_of_month, end_of_last_month)
  end

  def self.this_month
    where('date between ? AND ?', Date.today.at_beginning_of_month, Date.today.at_end_of_month)
  end

  def self.last_week
    where('date between ? AND ?', Date.today.at_beginning_of_week-7, Date.today.at_end_of_week-7)
  end

  def self.this_week
    where('date between ? AND ?', Date.today.at_beginning_of_week, Date.today.at_end_of_week)
  end
end
