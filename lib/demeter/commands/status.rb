require 'colorize'
require 'demeter/aws/manage_security_groups'
require 'terminal-table'
require_relative 'base'

module Demeter
  module Commands
    class Status < Base
      def start
        sgs_manager = Demeter::Aws::ManageSecurityGroups.new(ec2:@ec2, options:@options)
        status = sgs_manager.status
        rows = []
 
        rows << [{:value => "### MANAGED SECURITY GROUPS ###".colorize(:green), :colspan => 3, :alignment => :left}]
        rows << :separator
        rows << ['Name', 'Group Name', 'Group ID']
        rows << :separator
        
        status[:managed].each do |sg|
          rows << [sg[:name], sg[:group_name], sg[:group_id]]
        end 
        
        rows << :separator
        rows << [{:value => "### UNMANAGED SECURITY GROUPS ###".colorize(:red), :colspan => 3, :alignment => :left}]
        rows << :separator
        rows << ['Name', 'Group Name', 'Group ID']
        rows << :separator
        
        status[:unmanaged].each do |sg|
          rows << [sg[:name], sg[:group_name], sg[:group_id]]
        end 
      
        puts Terminal::Table.new :rows => rows
 
        puts ""
        puts "#{'MANAGED'.colorize(:green)}: #{status[:managed].count}" 
        puts "#{'UNMANAGED'.colorize(:red)}: #{status[:unmanaged].count}"
        puts ""
      end
    end
  end
end
