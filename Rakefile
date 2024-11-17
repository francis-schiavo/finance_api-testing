# frozen_string_literal: true
require_relative 'test_runner'

task :test_v1 do
  TestRunner.new('v1').run 20
end

task :test_v2 do
  TestRunner.new('v2').run 20
end

task default: :test
