class Appointment < ActiveRecord::Base
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  include ActiveModel::Validations
  validates_with AppointmentDateValidator

  def reformat_date_from_string
    DateTime.strptime(self.start_time, '%m/%d/%Y %H:%M')
  end

  def set_date_search_variables(appt_params)
    # Set Defaults
    now = DateTime.now
    beg_hour = now.hour
    end_hour = now.hour + 1.hours
    beg_day = now.day
    end_day = now.day + 1.days
    beg_month = now.month
    end_month = now.month + 1.months
    beg_year = now.year
    end_year = now.year + 1.years
    # Weeks don't work in combination with hour, day, month, year
    # beg_week = now.beginning_of_week
    # end_week = now.end_of_week
    # add weeks search option if time is available

    # Replace with params (if given)
    beg_hour = appt_params[:hour] if appt_params[:hour]
    end_hour = (appt_params[:hour] + 1.hours) if appt_params[:hour]
    beg_day = appt_params[:day] if appt_params[:day]
    end_day = (appt_params[:day] + 1.days) if appt_params[:day]
    beg_month = appt_params[:month] if appt_params[:month]
    end_month = (appt_params[:month] + 1.months) if appt_params[:month]
    beg_year = appt_params[:year] if appt_params[:year]
    end_year = (appt_params[:year] + 1.years) if appt_params[:year]

    # Create new datetime object
    beg_date = DateTime.new(beg_year, beg_month, beg_day, beg_hour)
    end_date = DateTime.new(end_year, end_month, end_day, end_hour)
    new_params = appt_params
    appt_params[:start_time] = date
    appt_params[:end_time] = date
    appt_params.delete(:hour) if !new_params[:hour].nil?
    appt_params.delete(:day) if !new_params[:day].nil?
    appt_params.delete(:month) if !new_params[:month].nil?
    appt_params.delete(:year) if !new_params[:year].nil?
    p "*" * 50
    p beg_date
    p end_date
    p appt_params
    p "*" * 50
    new_params
  end

end
