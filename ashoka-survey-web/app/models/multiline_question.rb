class MultilineQuestion < Question 
  attr_accessible :max_length
  validates_numericality_of :max_length, :only => :integer, :greater_than => 0, :allow_nil => true
  validates :max_length, length: { maximum: 15, message: "should be less than 15 digits"}
end