class Appointment < ActiveRecord::Base
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true

  def reformat_date_from_string
    DateTime.strptime(self.start_time, '%m/%d/%Y %H:%M')
  end

  def valid_dates?
    if self.start_time <= Time.now
      return false
    end
    if self.end_time <= Time.now
      return false
    end
    true
  end

end
