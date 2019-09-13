require "optparse"
require "ostruct"

module DBug
  module CLI
    module_function

    def parse
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: d-bug [options] PATH COMMAND"
        opts.separator "Options:\n"
        # opts.on("-s", "--serial-port=PATH", "Path to USB Serial Port like /dev/ttyUSB0") { |port| options[:port] = port }
        opts.on("-e", "--exclude=PATTERN", "Ignore file pattern") { |exclude| options[:exclude] = exclude }
        opts.on("-o", "--only=PATTERN", "Accept only file pattern") { |only| options[:only] = only }
        opts.on("-d", "--debug", "Run in debug mode") { options[:debug] = true }
        opts.on("-v", "--version", "Print current version") { options[:version] = true }
        opts.on("-h", "--help", "Prints this help")
        opts.separator "\nExample: d-bug -o .rb ./spec 'docker exec -t container_name bundle exec rspec {}'\n\n"
      end
      parser.parse!(options)
      options[:path], *options[:command] = ARGV

      puts "[#{self.to_s}] options #{options.inspect}" if DBug.debug?
      raise ArgumentError unless options[:version] || (options[:path] && !options[:command].empty?)

      OpenStruct.new(options)
    rescue ArgumentError, OptionParser::InvalidOption
      puts "Invalid Option"
      puts parser
      exit 1
    end

  end
end
