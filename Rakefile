require 'rubygems'
require 'rake'

begin
    require 'jeweler'
    Jeweler::Tasks.new do |gem|
        gem.name = "mongoid_tree"
        gem.summary = %Q{Materialized paths based tree implementation for Mongoid}
        gem.description = %Q{Fully featured tree implementation for Mongoid using materialized paths and relative associations. Featuring Depth and Breadth first search.}
        gem.email = "rkuhn@littleweblab.com"
        gem.homepage = "http://github.com/rayls/mongoid_tree"
        gem.authors = ["Rainer Kuhn"]
        # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    end
    Jeweler::GemcutterTasks.new
rescue LoadError
    puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec'
require 'rspec/core/rake_task'
Rspec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = "spec/**/*_spec.rb"
end

Rspec::Core::RakeTask.new(:rcov) do |spec|
    spec.pattern = "spec/**/*_spec.rb"
    spec.rcov = true
end

task :spec => :check_dependencies

begin
    require 'cucumber/rake/task'
    Cucumber::Rake::Task.new(:features)

    task :features => :check_dependencies
rescue LoadError
    task :features do
        abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
    end
end

task :default => :spec

begin
    require 'yard'
    YARD::Rake::YardocTask.new
rescue LoadError
    task :yardoc do
        abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
    end
end
