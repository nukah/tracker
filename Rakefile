require './configuration'
require 'resque/tasks'

task :start, [:amount] do |task, args|
  ENV['QUEUE'] = Settings.subscriber_queue
#  ENV['BACKGROUND'] = 'yes'
  Rake::Task['resque:work'].execute()
end
