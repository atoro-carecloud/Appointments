class AppointmentsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  # Worried about security of this line!

  def crud_master
    case clud_method_from_params[:m]
    when "create"
      create
    when "update"
      update
    when "delete"
      destroy
    else
      list
    end
  end

  def list
    find_appointment
    render json: @appointments
  end

  def create
    p "method_basic_params #{basic_params}"
    basic_params = reformat_params_date
    # p "create" * 20
    # p basic_params
    # p "create" * 20
    # p @create_success
    if @create_success
      @appointment = Appointment.new(basic_params)
      if @appointment.save
        render status: 200, json: {
          message: "Successfully created appointment",
          appointment: @appointment
        }.to_json
      else
        render status: 422, json: {
          errors: @appointment.errors
        }.to_json
      end
    end
  end

  def render_update_fail(zero_results = false)
    zero_results == false ? msg = "More than one result" : msg = "No result found"
    render status: 422, json: {
      message: "Update failed: #{msg}."
    }.to_json
  end

  def adjust_update_to_params(appointment, update_to_params, current_params)
    update_to_params.each do |key, value|
      new_key = key.(to_s[2..-1] + "=").to_sym
      key = new_key
    end
  end

  ### Left off here trying to refactor. This update method needs it badly.
  ### Just go crazy and refactor this whole thing. It's getting really messy.
  ### Dont't forget this area. It's very important!

  def update
    if all_allowed_params == {}
      @appointments = Appointment.all
    else
      @appointments = Appointment.where(Appointment.new.set_date_search_variables(all_allowed_params))
      if @appointments.length == 1
        @appointment = @appointments.first
        u_params = update_params
        final_u_params = all_allowed_params
        u_params.each do |key, value|
          new_key = key.to_s[2..-1]
          p "new_key: #{new_key}"
          final_u_params[new_key] = value
        end
        p "final_u_params: #{final_u_params}"
      elsif @appointments.length > 1
        render_update_fail(false)
        return @appointments
      elsif @appointments.length < 1
        render_update_fail(true)
        return @appointments
      end
    end
    final_u_params[:start_time] = reformat_date(final_u_params[:start_time])
    final_u_params[:end_time] = reformat_date(final_u_params[:end_time])
    p "&*" * 25
    p final_u_params
    p "&*" * 25
    if @appointment.update(final_u_params)
      p "#{@appointment} updated"
    end
    render status: 200, json: {
      message: "Successfully updated Appointment",
      appointment: @appointment
    }.to_json
  end

  def destroy
    if all_allowed_params == {}
      @appointments = Appointment.all
    else
      @appointments = Appointment.where(Appointment.new.set_date_search_variables(all_allowed_params))
      if @appointments.length == 1
        @appointment = @appointments.first
      elsif @appointments.length > 1
        render status: 422, json: {
          message: "Delete failed: More than one result"
        }.to_json
        return @appointments
      elsif @appointments.length < 1
        render status: 422, json: {
          message: "Delete failed: No result found"
        }.to_json
        return @appointments
      end
    end
    p "#{@appointment} deleted"
    @appointment.destroy
    render status: 200, json: {
      message: "Successfully deleted Appointment",
      appointment: @appointment
    }.to_json
  end

  private

  # New methods (after refactoring) ----------------------------------------->
  def find_appointment
    if basic_params == {}
      @appointments = Appointment.all
    else
      @appointments = Appointment.where(Appointment.new.set_date_search_variables(basic_params))
    end
  end
  # New methods (after refactoring) ----------------------------------------->


  # Params organization section ----------------------------------------->

  def all_allowed_params
    params.permit(:first_name, :last_name, :start_time, :end_time, :comments,
                  :min, :hour, :day, :month, :year, :m, :n_first_name,
                  :n_last_name, :n_start_time, :n_end_time, :n_commments)
  end

  def clud_method_from_params
    all_allowed_params.slice(:m)
  end

  def update_params
    all_allowed_params.slice(:n_first_name, :n_last_name, :n_start_time,
                             :n_end_time, :n_comments)
  end

  def basic_params
    all_allowed_params.slice(:first_name, :last_name, :start_time, :end_time, :comments)
  end

  def reformat_date(date_user_input_format)
    DateTime.strptime(date_user_input_format, '%m/%d/%Y %H:%M') + 2000.years
  end

  # Params organization section ----------------------------------------->

  def reformat_params_date
    @create_success = true
    new_params = all_allowed_params
    p "&" * 50
    p new_params
    p "&" * 50
    begin
      if new_params[:start_time]
        new_params[:start_time] = DateTime
          .strptime(new_params[:start_time], '%m/%d/%Y %H:%M') + 2000.years
      end
      if new_params[:start_time]
        new_params[:end_time] = DateTime
          .strptime(new_params[:end_time], '%m/%d/%Y %H:%M') + 2000.years
      end
      return new_params
    rescue
      @create_success = false
      error = "One of your dates is invalid."
      render status: 422, json: {
        errors: error
      }.to_json
    end
  end

end
