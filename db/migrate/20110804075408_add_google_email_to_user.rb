class AddGoogleEmailToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :google_email, :string
  end

  def self.down
    remove_column :users, :google_email
  end
end
