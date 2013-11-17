require 'optparse'
require 'logger'
require 'yaml'


module CloudDyndns

  class Config

    def usage_banner
      <<-EOF
    USAGE:  cloud-dyndns --config [/path/to/config.yaml] --log [/path/to/log]
      EOF
    end

    def config_instructions
      'Path to config file (required)'
    end

    def log_instructions
      'Path to log file (if not given, will write to stdout)'
    end

    def initialize(args)
      check_args(args)

      parser = OptionParser.new do |opts|
        opts.banner = usage_banner

        opts.on '-c', '--config PATH', config_instructions do |v|
          set_config!(v)
        end

        opts.on '-l', '--log [PATH]', log_instructions do |v|
          set_log!(v)
        end
      end

      parser.parse!(args)
    end

    def log
      @log ||= ::Logger.new(@log_path || STDOUT)
    end

    def config
      @config ||= ::YAML.load_file(@config_path)
    end

    private

    def check_args(args)
      if !args or args.length == 0
        puts usage_banner
        exit(1)
      end
    end

    def set_config!(path)
      @config_path = File.expand_path(path) if path
    end

    def set_log!(path)
      @log_path = path
      ::Kernel.at_exit { @log.close() if @log }
    end
  end
end
