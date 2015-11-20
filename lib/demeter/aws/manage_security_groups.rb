require 'aws-sdk'
require 'yaml'
require 'demeter/aws/security_group.rb'
require 'colorize'

module Demeter
  module Aws
    class ManageSecurityGroups
      def initialize(ec2:, project_path: File.join(Demeter::root, "/configs/**/*.yml"), options:{})
        @ec2 = ec2
        @sgs = {}
        @project_path = project_path  
        @options = options
      end

      # Returns array of diffs
      def diff_all
        describe
        all_diffs = {}
        @sgs.each do |key, sg|
          diff = sg.diff
          if diff.any?
            all_diffs[key] = diff
          end
        end
        all_diffs
      end

      def create_all
        describe
        @sgs.each do |key, sg|
          sg.create
        end
      end

      def modify_all
        describe
        @sgs.each do |key, sg|
          sg.modify
        end
      end

      def apply
        create_all
        modify_all
      end
      
      def status
        status = {managed: [], unmanaged: []}
        local_sgs = []

        Dir.glob(@project_path).each do |path|
          project_config = YAML::load_file(path)
          
          next if !project_config
          next if project_config['environments'] && @options['environment'] && !project_config['environments'].include?(@options['environment'])
          
          if project_config && project_config['security_groups']
            project_config['security_groups'].each do |local_sg|
              local_sgs << local_sg['name']
            end
          end
        end

        res = @ec2.describe_security_groups
        res[:security_groups].each do |object|
          name_tag = object['tags'].detect{|tag| tag['key'].downcase == 'name'}
          if name_tag && local_sgs.include?(name_tag['value'])
            status[:managed] << {
              name: name_tag['value'],
              group_id: object.group_id,
              group_name: object.group_name
            }
          else
            status[:unmanaged] << {
              name: (name_tag ? name_tag['value'] : ''),
              group_id: object.group_id,
              group_name: object.group_name
            }
          end
        end
        status[:managed].sort_by!{|x| x[:name]}
        status[:unmanaged].sort_by!{|x| x[:name]}
        status
      end

      def describe()
        Dir.glob(@project_path).each do |path|
          project_config = YAML::load_file(path)
          
          next if !project_config
          next if project_config['environments'] && @options['environment'] && !project_config['environments'].include?(@options['environment'])

          if project_config && project_config['security_groups']
            project_config['security_groups'].each do |local_sg|
              sg = Demeter::Aws::SecurityGroup.new(@ec2)
              sg.load_local(local_sg)
              @sgs[sg.hash] = sg
            end
          end
        end
        
        res = @ec2.describe_security_groups
        res[:security_groups].each do |object|
          name_tag =  object['tags'].detect{|tag| tag['key'].downcase == 'name'}
          if name_tag && @sgs.include?(name_tag['value'])
            @sgs[name_tag['value']].load_aws(object)
          end
        end
      end
    end
  end
end
