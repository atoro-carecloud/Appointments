class AppointmentsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  # Worried about security of this line!


  def index
    @appointments = Appointment.all
    render json: @appointments
  end

  def show
    @appointment = Appointment.find(params[:id])
    render json: @appointment
  end

  def create
    @appointment = Appointment.new(reformat_params_date)
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
    params.permit(:first_name, :last_name, :start_time, :end_time, :comments)
  end

  def reformat_params_date
    new_params = appt_params
    new_params[:start_time] = DateTime.strptime(new_params[:start_time], '%m/%d/%Y %H:%M')
    new_params[:start_time] = new_params[:start_time] + 2000.years
    new_params[:end_time] = DateTime.strptime(new_params[:end_time], '%m/%d/%Y %H:%M')
    new_params[:end_time] = new_params[:end_time] + 2000.years
    new_params
  end

end
