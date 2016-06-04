class AppointmentsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  # Worried about security of this line!

  def crud_master
    case crud_params[:m]
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
    if appt_params == {}
      @appointments = Appointment.all
    else
      @appointments = Appointment.where(Appointment.new.set_date_search_variables(appt_params))
    end
    render json: @appointments
  end

  def show
    @appointment = Appointment.find(params[:id])
    render json: @appointment
  end

  def create
    create_params = reformat_params_date
    if @create_success
      @appointment = Appointment.new(create_params)
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

  def update
    @appointment = Appointment.find(params[:id])
    if @appointment.update(appt_params)
      render status: 200, json: {
        message: "Successfully updated",
        appointment: @appointment
      }.to_json
    else
      render status: 422, json: {
        message: "Appointment not updated",
        appointment: @appointment
      }.to_json
    end
  end

  def destroy
    if appt_params == {}
      @appointments = Appointment.all
    else
      @appointments = Appointment.where(Appointment.new.set_date_search_variables(appt_params))
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
  def appt_params
    params.permit(:first_name, :last_name, :start_time, :end_time, :comments,
                  :min, :hour, :day, :month, :year)
  end

  def crud_params
    params.permit(:m)
  end

  def create_params
    params.permit(:first_name, :last_name, :start_time, :end_time, :comments)
  end

  def reformat_params_date
    @create_success = true
    new_params = validate_times
    begin
      new_params[:start_time] = DateTime
        .strptime(new_params[:start_time], '%m/%d/%Y %H:%M') + 2000.years
      new_params[:end_time] = DateTime
        .strptime(new_params[:end_time], '%m/%d/%Y %H:%M') + 2000.years
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
