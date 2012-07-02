require 'resque/tasks'

class Update
  @queue = :requests
  
  def self.perform(id = nil)
    
  end
end