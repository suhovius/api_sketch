# Output info message to console.
#
# @param message [String] message to output
def puts_info(message)
  $stdout.puts "\e[32m[INFO] #{message}\e[0m" if ApiSketch::Config[:debug]
end

# Output warning message to console.
#
# @param message [String] message to output
def puts_warning(message)
  $stdout.puts "\e[33m[WARNING] #{message}\e[0m" if ApiSketch::Config[:debug]
end

# Output error message to console.
#
# @param message [String] message to output
def puts_error(message)
  $stderr.puts "\e[31m[ERROR] #{message}\e[0m" if ApiSketch::Config[:debug]
  exit(1)
end