class AppointmentDateValidator < ActiveModel::Validator

  def validate(record)
    set_appointments_to_test_against
    p "@" * 50
    p @upcoming_appts
    p "record: #{record}"
    p record
    p "@" * 50

    # Left off here, testing create again. Getting error on record being nil in
    # is_start_time_formatted method

    is_start_time_formatted?(record)
    is_end_time_formatted?(record)
    is_end_after_start?(record)
    @upcoming_appts.each do |appt|
      does_start_time_conflict?(record, appt)
      does_end_time_conflict?(record, appt)
      do_times_surround_another?(record, appt)
    end
    p "$" * 50
    p record.errors[:base]
    p "$" * 50
  end

  def set_appointments_to_test_against
    now_until_future = Time.now..(Time.now + 50.years)
    @upcoming_appts = Appointment.where(start_time: now_until_future)
  end

  def is_start_time_formatted?(record)
    if record.start_time < Time.now
      record.errors[:base] << "Start time is either (a) not properly " +
      "formatted, or (b) in the past."
    end
  end

  def is_end_time_formatted?(record)
    if record.end_time < Time.now
      record.errors[:base] << "End time is either (a) not properly " +
      "formatted, or (b) in the past."
    end
  end

  def is_end_after_start?(record)
    if record.start_time >= record.end_time
      record.errors[:base] << "End time must be after start time."
    end
  end

  def does_start_time_conflict?(record, appt)
    p "*" * 50
    p "record.start_time: #{record.start_time}"
    p "appt.start_time: #{appt.start_time}"
    p "record.end_time: #{record.end_time}"
    p "*" * 50
    if record.start_time >= appt.start_time && record.start_time < appt.end_time
      # invalid
      record.errors[:base]  << "Start time occurs during another appointment."
    end
  end

  def does_end_time_conflict?(record, appt)
    if record.end_time > appt.start_time && record.end_time <= appt.end_time
      # invalid
      record.errors[:base] << "End time occurs during another appointment."
    end
  end

  def do_times_surround_another?(record, appt)
    if record.start_time <= appt.start_time && record.end_time >= appt.end_time
      # invalid
      record.errors[:base] << "Times overlap another appointment."
    end
  end

end
