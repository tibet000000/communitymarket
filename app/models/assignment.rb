class Assignment < ActiveRecord::Base
  # The join table for Posts and Groups they are assigned to
  
  attr_accessible :group_id, :post_id
  belongs_to :post
  belongs_to :group
  
  def get_assignment_post_id(assignments)
    return assignments.first(:order => "RANDOM()").post_id
  end
end
