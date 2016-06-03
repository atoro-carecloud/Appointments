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

# Problem here where first_name search, start_date search do not work.
# At least in that first case, it DOES work when some dates are included.
# Also displays empty JSON when no criteria are given
# Work on this!

  def set_date_search_variables(appt_params)

    # Determine most specific time search criteria
    @search_spec = get_date_search_specificity(appt_params)

    # Set default beg_times
    set_beg_times_initial
    # Reset beg_times if params are given
    replace_beg_times_with_params(appt_params)

    # Set default end_times
    set_end_times_initial
    # Reset end_times if params are given
    adjust_times_on_search_spec

    # Creates date objects and range of those objects
    set_beg_end_dates

    # Pushes date_range back into appt_params
    appt_params[:start_time] = @date_range

    # Removes params not in database and returns appt_params
    delete_unsearchable_params(appt_params)
  end

  def set_beg_times_initial
    now = DateTime.now
    @beg_hour = now.hour
    @beg_month = now.month
    @beg_day = now.day
    @beg_year = now.year
  end

  def replace_beg_times_with_params(appt_params)
    @beg_hour = appt_params[:hour].to_i if appt_params[:hour]
    @beg_day = appt_params[:day].to_i if appt_params[:day]
    @beg_month = appt_params[:month].to_i if appt_params[:month]
    @beg_year = appt_params[:year].to_i if appt_params[:year]
  end

  def set_end_times_initial
    @end_hour = @beg_hour
    @end_day = @beg_day
    @end_month = @beg_month
    @end_year = @beg_year
  end

  def adjust_times_on_search_spec
    if @search_spec == :hour
      if @beg_hour == 23
        @end_hour = 0
      else
        @end_hour = @beg_hour + 1
      end
    elsif @search_spec == :day
      if @beg_day == Time.days_in_month(@beg_month, @beg_year)
        @end_day = 1
      else
        @end_day = @beg_day + 1
      end
      @beg_hour = 0
      @end_hour = 0
    elsif @search_spec == :month
      if @beg_month == 12
        @end_month = 1
      else
        @end_month = @beg_month + 1
      end
      @beg_hour = 0
      @end_hour = 0
      @beg_day = 1
      @end_day = 1
    elsif @search_spec == :year
      @beg_hour = 0
      @end_hour = 0
      @beg_day = 1
      @end_day = 1
      @beg_month = 1
      @end_month = 1
      @end_year = @beg_year + 1
    else
      if @beg_day == Time.days_in_month(@beg_month, @beg_year)
        @end_day = 1
        @end_month = @end_month + 1
      else
        @end_day = @beg_day + 1
      end
      @beg_hour = 0
      @end_hour = 0
    end
  end

  def set_beg_end_dates
    @beg_date = DateTime.new(@beg_year, @beg_month, @beg_day, @beg_hour)
    @end_date = DateTime.new(@end_year, @end_month, @end_day, @end_hour) - 1.seconds
    @date_range = @beg_date..@end_date
  end

  def get_date_search_specificity(params)
    if params[:hour]
      return :hour
    elsif params[:day]
      return :day
    elsif params[:month]
      return :month
    elsif params[:year]
      return :year
    end
  end

  def delete_unsearchable_params(appt_params)
    appt_params.delete(:hour) if !appt_params[:hour].nil?
    appt_params.delete(:day) if !appt_params[:day].nil?
    appt_params.delete(:month) if !appt_params[:month].nil?
    appt_params.delete(:year) if !appt_params[:year].nil?
    appt_params
  end
end
