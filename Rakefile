require 'rake/testtask'

Rake::TestTask.new do |task|
  task.libs << 'test'
  task.test_files = FileList['test/**/*_test.rb']
end

# Finds the code files that outgrew the length the style guide allows.
module FileLength
  # The longest a code file may be, blank and comment lines counted.
  MAX = 100

  # The code we write, as opposed to prose, markup and data.
  CODE = /\.(rake|rb)\z|\ARakefile\z/

  # @return [Array<Array>] every tracked code file over the limit, longest first.
  def self.offenders
    `git ls-files`.split("\n").grep(CODE).
      map { |path| [ path, File.readlines(path).size ] }.
      select { |_path, lines| lines > MAX }.
      sort_by { |_path, lines| -lines }
  end
end

desc 'Fail when a tracked code file runs longer than 100 lines'
task :file_length do
  offenders = FileLength.offenders
  offenders.each { |path, lines| puts "#{path}: #{lines} lines" }
  abort "#{offenders.size} file(s) over #{FileLength::MAX} lines" unless offenders.empty?
  puts "No tracked code file over #{FileLength::MAX} lines"
end

task default: %i[file_length test]
