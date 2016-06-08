class AppointmentsController < ApplicationController
  skip_before_filter :verify_authenticity_token
# <------------------------ CLUD Master ---------------------------------->
  def clud_master
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

  # <------------------------ CLUD Methods ---------------------------------->

  def list
    errors = []
    list_params = search_params
    appointments = Appointment.set_appointments_if_params(list_params)

    if errors == []
      render status: 200, json: appointments
    else
      render_errors(errors)
    end
  end

  def create
    errors = []
    create_params = basic_params
    appointment, errors = Appointment.create_appointment(create_params, errors)

    if errors == []
      render status: 200, json: {
        message: "Saved successfully!",
        appointment: appointment
      }.to_json
    else
      render_errors(errors)
    end
  end

  def update
    # Find Appointment
    errors = []
    list_params = search_params
    appointments = Appointment.set_appointments_if_params(list_params)
    u_params = update_params

    appointment, errors = Appointment.one_search_result(appointments, errors)
    appointment, errors = appointment.update_appointment(u_params, errors) if errors == []
    # Render
    if errors == []
      render status: 200, json: {
        message: "Updated successfully!",
        appointment: appointment
      }.to_json
    else
      render_errors(errors)
    end
  end

  def destroy
    errors = []
    list_params = search_params
    appointments = Appointment.set_appointments_if_params(list_params)
    appointment, errors = Appointment.one_search_result(appointments, errors)
    errors = appointment.delete_appointment(errors) if appointment
    if errors == []
      render status: 200, json: {
        message: "Deleted successfully!",
        appointment: appointment
      }.to_json
    else
      render_errors(errors)
    end
  end

  # <------------------------ Params Methods -------------------------------->
  def all_allowed_params
      params.permit(:first_name, :last_name, :start_time, :end_time, :comments,
                    :min, :hour, :day, :month, :year, :m, :n_first_name,
                    :n_last_name, :n_start_time, :n_end_time, :n_commments)
  end

  def clud_method_from_params
    all_allowed_params.slice(:m)
  end

  def search_params
    all_allowed_params.slice(:first_name, :last_name, :start_time, :end_time,
                             :comments, :min, :hour, :day, :month, :year)
  end

  def update_params
    all_allowed_params.slice(:n_first_name, :n_last_name, :n_start_time,
                             :n_end_time, :n_comments)
  end

  def basic_params
    all_allowed_params.slice(:first_name, :last_name, :start_time, :end_time, :comments)
  end

  # <------------------------ Render Methods -------------------------------->
  def render_errors(errors)
    render status: 422, json: {
      errors: errors
    }.to_json
  end

  # <------------------------ Setter Methods -------------------------------->
end
