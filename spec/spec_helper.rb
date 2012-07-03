# -*- encoding : utf-8 -*-
require 'bundler/setup'
Bundler.require :default, :test 
require 'sinatra'
require 'rspec'
require 'machinist'
require 'machinist_mongoid'

RSpec.configure do |config|
  config.before(:each) { Machinist.reset_before_test }
end

Tracking.blueprint do
  tid { 'RA536006335CN' }
  status { 'Priem' }
  updated { Time.now }
  country { 'Russia' }
end

