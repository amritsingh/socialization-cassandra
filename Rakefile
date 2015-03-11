require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'

desc 'Test the socialization plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
