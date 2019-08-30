require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs.push "lib", "test"
  t.test_files = FileList["test/**/*_test.rb"]
  # t.verbose = true
end

task :default => :test

task :install do
  `rm -f d_bug*.gem`
  `sudo gem uninstall --force --all --executables d_bug`
  `gem build d_bug.gemspec`
  `sudo gem install d_bug`
end
