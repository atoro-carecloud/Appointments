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
    @appointment = Appointment.new(appt_params)
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
    params.require("appointment")
          .permit(:first_name, :last_name, :start_time, :end_time, :comments)
  end

end
