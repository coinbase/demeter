require 'thor'

module Demeter
  class Cli < Thor
    # include Thor::Actions
  
    option :debug, desc: 'displays the debug backtrace', type: :boolean, default: false
    def initialize(args = [], local_options = {}, config = {})
      super
    end

    desc 'version', 'prints Demeter version'
    long_desc <<-EOS
    `demeter version` prints the version of the app.
    EOS
    def version
      puts "v#{Demeter::VERSION}"
    end


    desc 'status', 'Show current status of maneged and unmaneged security groups'
    long_desc <<-EOS
    `demeter status` shows current status of managed and unmaneged security groups.

    $ > demeter plan -e development
    EOS
    option :environment, aliases: '-e', :required => true, desc: 'The environment to plan against'
    def status
      if options[:help]
        invoke :help, ['status']
      else
        require 'demeter/commands/status'
        Demeter::Commands::Status.new(options).start
      end
    end


    desc 'plan', 'Generate and show an execution plan'
    long_desc <<-EOS
    `demeter plan` generates and shows the execution plan.

    $ > demeter plan -e development
    EOS
    option :environment, aliases: '-e', :required => true, desc: 'The environment to plan against'
    def plan
      if options[:help]
        invoke :help, ['plan']
      else
        require 'demeter/commands/plan'
        Demeter::Commands::Plan.new(options).start
      end
    end


    desc 'apply', 'Apply an execution plan'
    long_desc <<-EOS
    `demeter apply` applies the execution plan.

    $ > demeter apply -e development
    EOS
    option :environment, aliases: '-e', :required => true, desc: 'The environment to plan against'
    def apply
      if options[:help]
        invoke :help, ['apply']
      else
        require 'demeter/commands/apply'
        Demeter::Commands::Apply.new(options).start
      end
    end


    desc 'generate', 'Generate local config from aws describe call'
    long_desc <<-EOS
    `demeter generate -e development -ids <sg-id> ...` 

    $ > demeter generate -e development -ids sg-000000 sg-111111

    $ > demeter generate -e development -ids sg-000000
    EOS
    option :environment, aliases: '-e', :required => true, desc: 'The environment to plan against'
    option :ids, aliases: '-ids', type: :array, :required => true, desc: 'List of security group ids (sg-000000)'
    def generate
      if options[:help]
        invoke :help, ['generate']
      else
        require 'demeter/commands/generate'
        Demeter::Commands::Generate.new(options).start
      end
    end

  end
end
