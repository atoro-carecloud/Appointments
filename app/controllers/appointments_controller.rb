class AppointmentsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  # Worried about security of this line!

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
    @appointment = Appointment.find(params[:id])
    @appointment.destroy
    render status: 200, json: {
      message: "Successfully deleted Appointment"
    }.to_json
  end

  private
  def appt_params
    params.permit(:first_name, :last_name, :start_time, :end_time, :comments,
                  :hour, :day, :month, :year, :week)
  end

  def reformat_params_date
    @create_success = true
    new_params = appt_params
    begin
      new_params[:start_time] = DateTime
        .strptime(new_params[:start_time], '%m/%d/%Y %H:%M') + 2000.years
      new_params[:end_time] = DateTime
        .strptime(new_params[:end_time], '%m/%d/%Y %H:%M') + 2000.years
    rescue
      @create_success = false
      error = "One of your dates is invalid."
      render status: 422, json: {
        errors: error
      }.to_json
    end
  end

end
