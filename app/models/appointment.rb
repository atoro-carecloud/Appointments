class Appointment < ActiveRecord::Base
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true

  # <1----------------------- Search Method -------------------------------->
  def self.set_appointments_if_params(some_params)
    p "&*" * 30
    p some_params
    p "&*" * 30
    if some_params == {}
      find_appointments_all
    else
      some_params = downcase_first_last_names_hash(some_params)
      time_search_method = which_time_search_method?(some_params)
      send time_search_method, some_params
      # if time_search_method == "variable_time"
      #   prepare_and_run_var_time_search()
      # elsif time_search_method == "fixed_time"
      #   prepare_and_run_fix_time_search()
      # elsif time_search_method == "no_time"
      #   prepare_and_run_no_time_search(some_params)
      # end
    end
  end

      # <1A--------------set_appointments_if_params methods ----------------->
  def self.downcase_first_last_names_hash(some_params)
    some_params[:first_name].downcase! if some_params[:first_name]
    some_params[:last_name].downcase! if some_params[:last_name]
    some_params
  end

  def self.which_time_search_method?(some_params)
    if some_params[:min] || some_params[:hour] || some_params[:day] ||
      some_params[:month] || some_params[:year]
      :prepare_and_run_var_time_search
    elsif some_params[:start_time] || some_params[:end_time]
      :prepare_and_run_fix_time_search
    else
      :prepare_and_run_no_time_search
    end
  end

  def self.prepare_and_run_no_time_search(some_params)
    return where(some_params)
  end


  def self.find_appointments_all
    all
  end


  def self.get_time_search_specificity(some_params)

  end

  def self.find_appointments_by_search(some_params)
  end

end
