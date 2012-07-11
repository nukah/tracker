require './configuration'
require 'resque/tasks'

task :start, [:amount] do |task, args|
  ENV['QUEUE'] = Settings.subscriber_queue
  Rake::Task['resque:work'].execute()
end
