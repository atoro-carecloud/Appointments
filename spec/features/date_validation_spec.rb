require 'rails_helper'

feature 'Start and End Time Validation' do

  it "allows creation where dates are valid" do
    test_appt = Appointment.create(start_time: "11/8/17 15:10",
                                   end_time: "11/8/17 15:11",
                                   first_name: "Bill",
                                   last_name: "Golik")
    expect(Appointment.last).to eq(test_appt)
  end
  it "prevents creation where new appt start time is between any" +
     "other appointment's start and end time"
  it "prevents creation where new appt end time is between any" +
     "other appointment's start and end time"
  it "prevents creation where new appt times completely overlap" +
     "any other appointment's start and end time"
  it "prevents creation where new appt start time is in the past"
  it "prevents creation where new appt end time is in the past"
  it "prevents creation where new appt start time is after new appt end" +
     "time"
end
