require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs.push "lib", "test"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

task :uninstall do
  `gem uninstall --force --all --executables d_bug`
end

task reinstall: [:uninstall, :build, :'install:local']
