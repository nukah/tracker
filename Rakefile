require './configuration'
require 'resque/tasks'
module Tracker
  task :start, [:amount] do |task, args|
    ENV['QUEUE'] = Settings.subscriber_queue
    Rake::Task['work'].execute()
  end
end
