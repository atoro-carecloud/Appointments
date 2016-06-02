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

  # def is_time_taken?(datetime)
  #   @upcoming_appts = Appointment.where(
  #     start_time: Time.now..(Time.now + 999_999_999))
  #
  #     # Off to a good start here
  #     # Off to a good start here
  #     # Off to a good start here
  #
  # end

end
