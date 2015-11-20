require 'logger'

module Demeter
  module Commands
    class Base
      def initialize(options)
        check_path
        ENV['DEMETER_ENV'] = options['environment']
        Dotenv.load(".env.#{options['environment']}")
        ::Aws.config.update(:logger => Logger.new(STDOUT))
        @ec2 = ::Aws::EC2::Client.new()
        @options = options
      end

      def check_path
        fail "configs directory not found!" if !File.directory?('./configs')        
        fail "variables directory not found!" if !File.directory?('./variables')        
      end
    end
  end
end
