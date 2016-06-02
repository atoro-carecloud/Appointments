# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'

csv_text = File.read(Rails.root.join('lib', 'seeds', 'appt_data.csv'))
csv_text = csv_text.split("\r\r\n")
csv = []
csv_text.each do |x|
  csv << x.split(',')
end
csv.shift
p csv

csv.each do |row|
  # p row
  a = Appointment.new
  a.start_time = DateTime.strptime(row[0], '%m/%d/%Y %H:%M') + 2000.years
  a.end_time = DateTime.strptime(row[1], '%m/%d/%Y %H:%M') + 2000.years
  a.first_name = row[2]
  a.last_name = row[3]
  a.comments = row[4] if row[4].nil? == false
  a.save
  # p a
  puts "#{a.first_name} #{a.last_name}'s appointment is saved."
  puts "Starts at #{a.start_time} and ends at #{a.end_time}"
  puts "*" * 60
end
