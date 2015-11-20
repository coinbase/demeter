require 'colorize'
require 'demeter/aws/manage_security_groups'
require_relative 'base'

module Demeter
  module Commands
    class Generate < Base
      def initialize(options)
        super
        @ids = options[:ids]
      end
      
      def project_key name
        name
        .gsub('::', '_')
        .gsub('/', '_')
        .gsub('-', '_')
        .gsub(' ', '_')
        .downcase
      end

      def start
        # collect vars
        res = @ec2.describe_security_groups
        res[:security_groups].each do |object|
          name_tag = object['tags'].detect{|tag| tag['key'].downcase == 'name'}
          sg_key = name_tag ? project_key(name_tag['value']) : project_key(object.group_name)  
          Demeter::set_var("security_group.#{sg_key}.id", object.group_id)
          Demeter::set_var(object.group_id, "<% security_group.#{sg_key}.id %>")
        end

        resp = @ec2.describe_security_groups({group_ids: @ids})
        
        template = {
          'environments' => [@options['environment']],
          'security_groups' => []
        }

        resp[:security_groups].each do |_sg|
          name_tag = _sg['tags'].detect{|tag| tag['key'].downcase == 'name'}
          sg_key = name_tag ? project_key(name_tag['value']) : project_key(_sg.group_name)  
          
          sg_template = {
            'name' => (name_tag ? name_tag['value'] : _sg.group_name),
            'vpc_id' => '<% env.vpc_id %>',
            'ingress' => [],
            'egress' => []
          }
         
          # Ingress 
          _sg['ip_permissions'].each do |_rule|
            rule = {
              'protocol' => _rule.ip_protocol,
              'from_port' => _rule.from_port.to_i,
              'to_port' => _rule.to_port.to_i,
            }
            
            if !_rule['user_id_group_pairs'].empty?
              rule['source_security_groups'] = []
              _rule['user_id_group_pairs'].each do |_group|
                group_key = Demeter::vars[_group['group_id']] ? Demeter::vars[_group['group_id']] : _group['group_id']
                rule['source_security_groups'] << group_key 
              end
            end
 
            if !_rule['ip_ranges'].empty?
              rule['cidr_blocks'] = []
              _rule['ip_ranges'].each do |_range|
                rule['cidr_blocks'] << _range['cidr_ip']
              end
            end

            sg_template['ingress'] << rule
          end

          # Egress
          _sg['ip_permissions_egress'].each do |_rule|
            rule = {
              'protocol' => _rule.ip_protocol,
              'from_port' => _rule.from_port.to_i,
              'to_port' => _rule.to_port.to_i,
            }
            
            if !_rule['user_id_group_pairs'].empty?
              rule['source_security_groups'] = []
              _rule['user_id_group_pairs'].each do |_group|
                group_key = Demeter::vars[_group['group_id']] ? Demeter::vars[_group['group_id']] : _group['group_id']
                rule['source_security_groups'] << group_key 
              end
            end
 
            if !_rule['ip_ranges'].empty?
              rule['cidr_blocks'] = []
              _rule['ip_ranges'].each do |_range|
                rule['cidr_blocks'] << _range['cidr_ip']
              end
            end

            sg_template['egress'] << rule
          end

          template['security_groups'] << sg_template
        end

        puts template.to_yaml.gsub('"', '')
      end
    end
  end
end
