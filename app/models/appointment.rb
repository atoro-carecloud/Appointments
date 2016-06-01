class Appointment < ActiveRecord::Base

  def reformat_date_from_string
    DateTime.strptime(self.start_time, '%m/%d/%Y %H:%M')
  end
# 11/1/13 11:00,11/1/13 11:05,jennifer,edwards,

end
