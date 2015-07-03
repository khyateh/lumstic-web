class BrochureEnquiry < ActiveRecord::Base
  attr_accessible :count, :email, :name, :status
  validates_presence_of :name,:email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
end
