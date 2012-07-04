require './configuration'
require 'resque/tasks'
require 'resque_scheduler/tasks'

task :start, [:amount] do |task, args|
  ENV['QUEUE'] = @c.subscriber_queue
  ENV['VVERBOSE'] = 'TRUE'
#  ENV['BACKGROUND'] = 'yes'
  Rake::Task['resque:work'].execute()
end
