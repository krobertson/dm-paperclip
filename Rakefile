require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
 
# Console 
desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r dm-validations -r dm-migrations -r ./lib/dm-paperclip.rb"
end
 
# Test tasks
desc 'Test the DM-Paperclip library.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'dm-paperclip'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

task :coverage do
  system("rm -fr coverage")
  system("rcov test/test_*.rb")
  system("open coverage/index.html")
end