##require 'cucumber/rake/task' #I have to add this
#require 'spec/rake/spectask'
# 
#namespace :rcov do
#  #Cucumber::Rake::Task.new(:cucumber) do |t|    
#  #  t.rcov = true
#  #  t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/,features\/ --aggregate coverage.data}
#  #  t.rcov_opts << %[-o "coverage"]
#  #end
# 
#  Spec::Rake::SpecTask.new(:rspec) do |t|
#    t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
#    t.spec_files = FileList['spec/**/*_spec.rb']
#    t.rcov = true
#    t.rcov_opts = lambda do
#      IO.readlines("#{RAILS_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
#    end
#  end
# 
#  desc "Run both specs and features to generate aggregated coverage"
#  task :all do |t|
#    rm "coverage.data" if File.exist?("coverage.data")
#    #Rake::Task["rcov:cucumber"].invoke
#    Rake::Task["rcov:rspec"].invoke
#  end
#end

require 'rspec/core'
require 'rspec/core/rake_task'

spec_prereq = Rails.root.join('config', 'database.yml').exist? ? "db:test:prepare" : :noop


desc  "Run all specs with rcov"
RSpec::Core::RakeTask.new(:rcov => spec_prereq) do |t|
  t.rcov = true
  t.rcov_opts = %w{--rails --exclude osx\/objc,gems,bundler\/,spec\/,features\/}
end