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

    p "*" * 50
    p "appt_params: #{appt_params}"
    p "*" * 50
    # Pushes date_range back into appt_params if params were given

    if(appt_params[:min] ||
      appt_params[:hour] ||
      appt_params[:day] ||
      appt_params[:month] ||
      appt_params[:year])
      appt_params[:start_time] = @date_range
      # appt_params[:end_time] = @date_range
    end
    # Removes params not in database and returns appt_params
    delete_unsearchable_params(appt_params)
    ### Problem is that search will limit to today if there are no date params
  end

  def set_beg_times_initial
    now = DateTime.now
    @beg_min = now.min
    @beg_hour = now.hour
    @beg_month = now.month
    @beg_day = now.day
    @beg_year = now.year
  end

  def replace_beg_times_with_params(appt_params)
    @beg_min = appt_params[:min].to_i if appt_params[:min]
    @beg_hour = appt_params[:hour].to_i if appt_params[:hour]
    @beg_day = appt_params[:day].to_i if appt_params[:day]
    @beg_month = appt_params[:month].to_i if appt_params[:month]
    @beg_year = appt_params[:year].to_i if appt_params[:year]
  end

  def set_end_times_initial
    @end_min = @beg_min
    @end_hour = @beg_hour
    @end_day = @beg_day
    @end_month = @beg_month
    @end_year = @beg_year
  end

### This wordiness is absolutely terrible, refactor before submission, Mike
  def adjust_times_on_search_spec
    if @search_spec == :min
      if @beg_min == 59
        @end_min = 0
      else
        @end_min = @beg_min + 1
      end
    elsif @search_spec == :hour
      if @beg_hour == 23
        @end_hour = 0
      else
        @end_hour = @beg_hour + 1
      end
      @beg_min = 0
      @end_min = 0
    elsif @search_spec == :day
      if @beg_day == Time.days_in_month(@beg_month, @beg_year)
        @end_day = 1
      else
        @end_day = @beg_day + 1
      end
      @beg_hour = 0
      @end_hour = 0
      @beg_min = 0
      @end_min = 0
    elsif @search_spec == :month
      if @beg_month == 12
        @end_month = 1
      else
        @end_month = @beg_month + 1
      end
      @beg_min = 0
      @end_min = 0
      @beg_hour = 0
      @end_hour = 0
      @beg_day = 1
      @end_day = 1
    elsif @search_spec == :year
      @beg_min = 0
      @end_min = 0
      @beg_hour = 0
      @end_hour = 0
      @beg_day = 1
      @end_day = 1
      @beg_month = 1
      @end_month = 1
      @end_year = @beg_year + 1
    else
      # In case today is the last day of the month
      # if @beg_day == Time.days_in_month(@beg_month, @beg_year)
      #   @end_day = 1
      #   @end_month = @end_month + 1
      # else
      #   @end_day = @beg_day + 1
      # end
      @beg_hour = 0
      @end_hour = 0
    end
  end

  def set_beg_end_dates
    @beg_date = DateTime.new(@beg_year, @beg_month, @beg_day, @beg_hour, @beg_min)
    @end_date = DateTime.new(@end_year, @end_month, @end_day, @end_hour, @end_min) - 1.seconds
    @date_range = @beg_date..@end_date
  end

  def get_date_search_specificity(params)
    if params[:min]
      return :min
    elsif params[:hour]
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
    appt_params.delete(:min) if !appt_params[:min].nil?
    appt_params.delete(:hour) if !appt_params[:hour].nil?
    appt_params.delete(:day) if !appt_params[:day].nil?
    appt_params.delete(:month) if !appt_params[:month].nil?
    appt_params.delete(:year) if !appt_params[:year].nil?
    appt_params
  end
end
