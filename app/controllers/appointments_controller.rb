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
      render status: 200, json: appointment
    else
      render_errors(errors)
    end
  end

  def update
  end

  def destroy
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
