require 'demeter/aws/manage_security_groups'
require 'terminal-table'
require 'logger'
require_relative 'base'

module Demeter
  module Commands
    class Apply < Base
      def start
        sgs_manager = Demeter::Aws::ManageSecurityGroups.new(ec2:@ec2, options:@options)
        diff = sgs_manager.apply
      end
    end
  end
end
