class Appointment < ActiveRecord::Base
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true

  # <A----------------------- Search Method -------------------------------->
  def self.set_appointments_if_params(some_params)
    if some_params == {}
      find_appointments_all
    else
      some_params = downcase_first_last_names_hash(some_params)
      time_search_method = which_time_search_method?(some_params)
      send time_search_method, some_params
    end
  end

      # <A1--------------set_appointments_if_params methods ----------------->
  def self.find_appointments_all
    return all
  end

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

      # <A2-------------- main time_search_methods ------------------------->
  def self.prepare_and_run_var_time_search(some_params)
    date_params_keys = [:year, :month, :day, :hour, :min]
    param_spec = get_search_time_specificity(some_params, date_params_keys)
    some_params = convert_var_time_search_vals_to_i(some_params, date_params_keys)
    beg_times = set_date_hash_to_datetime(date_params_keys, {}, DateTime.now)
    beg_times = replace_date_hash_w_params(beg_times, some_params)
    beg_times = adjust_date_hash_by_specificity(end_times, param_spec, 'beg')
    end_times = adjust_date_hash_by_specificity(end_times, param_spec, 'end')
    end_times = beg_times
    p "&*" * 35
    p beg_times
  end

  def self.prepare_and_run_fix_time_search(some_params)
    some_params = convert_both_dates_str_to_dt(some_params)
    return where(some_params)
  end

  def self.prepare_and_run_no_time_search(some_params)
    return where(some_params)
  end
        # <A2a----------- support time_search_methods ---------------------->
  def self.convert_var_time_search_vals_to_i(some_params, date_params_keys)
    date_params_keys.each do |x|
      some_params[x] = some_params[x].to_i if some_params[x]
    end
    some_params
  end

  def self.get_search_time_specificity(some_params, date_params_keys)
    most_spec = nil
    date_params_keys.reverse.each_with_index do |x, i|
      if some_params[x]
        most_spec ||= date_params_keys.length - i - 1
      end
    end
    date_params_keys[0..most_spec]
  end

  def self.replace_date_hash_w_params(date_hash, some_params)
    date_hash.each do |k, v|
      some_params.each do |x, y|
        if k == x.to_sym
          date_hash[k] = y
        end
      end
    end
    date_hash
  end

  def self.adjust_date_hash_by_specificity(date_hash, specificity, beg_or_end)
    date_hash.each do |k, v|
      if !specificity.include?(k)
        if k == :month || k == :day
          if beg_or_end == 'beg'
            date_hash[k] = 1
          elsif beg_or_end == 'end'
            # date_hash[k] =
            # Keep working here
            #
            #
            #
            # 
          end
        elsif k == :hour || k == :min
          date_hash[k] = 0 if beg_or_end == 'beg'
        end
      end
    end
    date_hash
  end

# <----------------------- Date Manipulation Methods ------------------------->
  def self.convert_date_str_to_dt(str_time)
    DateTime.strptime("#{str_time} EST", '%m/%d/%Y %H:%M %Z') + 2000.years
  end

  def self.convert_both_dates_str_to_dt(some_params, dates = [:start_time, :end_time])
    dates.each do |x|
      some_params[x] = convert_date_str_to_dt(some_params[x]) if !some_params[x].nil?
    end
    some_params
  end

  def self.set_date_hash_to_datetime(date_params_keys, date_hash = {},
                                     datetime = DateTime.now)
    date_params_keys.each do |x|
      date_hash[x] = datetime.send x.to_sym
    end
    date_hash
  end

  def update_date_hash_with_params(date_hash, some_params, specificity)
    date_hash.keys.each do |x|
      date_hash[x] = some_params[x] if !some_params[x].nil?
      break if x == specificity
    end
    date_hash.each do |x, y|
      date_hash[x] = some_params[x] if !some_params[x].nil?
      break if x == specificity
    end
  end

end # Final End
