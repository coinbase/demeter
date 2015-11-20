require 'demeter/aws/manage_security_groups'
require 'terminal-table'
require_relative 'base'

module Demeter
  module Commands
    class Plan < Base
      def start
        sgs_manager = Demeter::Aws::ManageSecurityGroups.new(ec2: @ec2, options: @options)
        diff = sgs_manager.diff_all
        rows = []
        i = 0
        diff.each do |sg, diffs|
          rows << :separator if i > 0
          rows << [{:value => sg, :colspan => 3, :alignment => :left}]
          rows << :separator
 
          diffs.sort_by! { |d| d[0] }
          diffs.each do |_diff|
            if _diff[2].is_a? Array
              _diff[2].each do |__diff|
                rows << [_diff[0] == '+' ? _diff[0].colorize(:green) : _diff[0].colorize(:red), _diff[1], __diff.to_s]             
              end
            else
              rows << [_diff[0] == '+' ? _diff[0].colorize(:green) : _diff[0].colorize(:red), _diff[1], _diff[2].to_s] 
            end
          end
          i += 1
        end

        if rows.empty?
          puts "All #{Demeter::env} security groups are in sync"
        else
          table = Terminal::Table.new :rows => rows
          puts table
        end
      end
    end
  end
end
