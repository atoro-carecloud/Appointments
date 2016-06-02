class AddCommentsToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :comments, :text
  end
end
