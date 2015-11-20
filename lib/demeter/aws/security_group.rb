require 'digest/md5'
require 'hashdiff'

module Demeter
  module Aws
    class SecurityGroup
      def initialize(ec2)
        @ec2 = ec2
        @_sg = {}
        @_local_sg = {}
      end

      def group_id
        Demeter::vars["security_group.#{project_key}.id"]
      end

      def load_aws(object)
        if object.is_a?(::Aws::EC2::Types::SecurityGroup)
          name_tag = object['tags'].detect{|tag| tag['key'].downcase == 'name'}
          @_sg[:name] = (name_tag ? name_tag['value'] : object.group_name)
          @_sg[:description] = object.description
          @_sg[:vpc_id] = object.vpc_id
          @_sg[:ingress] = []
          @_sg[:egress] = []

          Demeter::set_var("security_group.#{project_key}.id", object.group_id)

          # INGRESS
          object.ip_permissions.each do |rule|
            rule.ip_ranges.each do |cidr_block|
              @_sg[:ingress] << {
                protocol: rule.ip_protocol.to_s,
                from_port: rule.from_port.to_i,
                to_port: rule.to_port.to_i,
                cidr_block: cidr_block.cidr_ip
              }    
            end

            rule.user_id_group_pairs.each do |source_security_group|
              @_sg[:ingress] << {
                protocol: rule.ip_protocol.to_s,
                from_port: rule.from_port.to_i,
                to_port: rule.to_port.to_i,
                source_security_group: source_security_group.group_id
              }
            end
          end

          # EGRESS
          object.ip_permissions_egress.each do |rule|
            rule.ip_ranges.each do |cidr_block|
              @_sg[:egress] << {
                protocol: rule.ip_protocol.to_s,
                from_port: rule.from_port.to_i,
                to_port: rule.to_port.to_i,
                cidr_block: cidr_block.cidr_ip
              }    
            end

            rule.user_id_group_pairs.each do |source_security_group|
              @_sg[:egress] << {
                protocol: rule.ip_protocol.to_s,
                from_port: rule.from_port.to_i,
                to_port: rule.to_port.to_i,
                source_security_group: source_security_group.group_id
              }
            end
          end
          return true  
        end
      end

      def load_local(object)
        if object.is_a?(Hash)
          @_local_sg[:name] = object['name']
          @_local_sg[:description] = 'Managed by Demeter'
          @_local_sg[:ingress] = []
          @_local_sg[:egress] = []
          @_local_sg[:vpc_id] = object['vpc_id']

          if !Demeter::vars.has_key?("security_group.#{project_key}.id")
            Demeter::set_var("security_group.#{project_key}.id", "security_group.#{project_key}.id")
          end

          # INGRESS 
          if object['ingress']
            object['ingress'].each do |rule|
              if rule.has_key?('cidr_blocks')  
                rule['cidr_blocks'].to_a.each do |cidr_block|
                  @_local_sg[:ingress] << {
                    protocol: rule['protocol'].to_s,
                    from_port: rule['from_port'].to_i,
                    to_port: rule['to_port'].to_i,
                    cidr_block: cidr_block
                  }    
                end
              end

              if rule.has_key?('source_security_groups') 
                rule['source_security_groups'].to_a.each do |source_security_group|
                  @_local_sg[:ingress] << {
                    protocol: rule['protocol'].to_s,
                    from_port: rule['from_port'].to_i,
                    to_port: rule['to_port'].to_i,
                    source_security_group: source_security_group
                  }
                end
              end
            end
          end 

          # EGRESS 
          if object['egress']
            object['egress'].each do |rule|
              if rule.has_key?('cidr_blocks') 
                rule['cidr_blocks'].to_a.each do |cidr_block|
                  @_local_sg[:egress] << {
                    protocol: rule['protocol'].to_s,
                    from_port: rule['from_port'].to_i,
                    to_port: rule['to_port'].to_i,
                    cidr_block: cidr_block
                  }    
                end
              end

              if rule.has_key?('source_security_groups') 
                rule['source_security_groups'].to_a.each do |source_security_group|
                  @_local_sg[:egress] << {
                    protocol: rule['protocol'].to_s,
                    from_port: rule['from_port'].to_i,
                    to_port: rule['to_port'].to_i,
                    source_security_group: source_security_group
                  }
                end
              end
            end
          end

          return true
        end
      end

      def security_group
        if @_sg.empty?
          @_local_sg
        else
          @_sg
        end
      end

      def hash
        group_name
      end

      def project_key
        security_group[:name]
          .gsub('::', '_')
          .gsub('/', '_')
          .gsub('-', '_')
          .gsub(' ', '_')
          .downcase
      end

      def project_name
        security_group[:name].split('::')[1]
      end

      def group_name 
        security_group[:name]
      end

      def diff
        sg = @_sg.select{ |key, value| true if key == :ingress || key == :egress }
        
        # update variables
        local_sg = update_vars(@_local_sg.select{ |key, value| true if key == :ingress || key == :egress })
        # update once again to replace deep variable links
        local_sg = update_vars(local_sg)

        if sg[:ingress]
          sg[:ingress].sort_by! { |x| x.to_s }
        end

        if local_sg[:ingress]
          local_sg[:ingress].sort_by! { |x| x.to_s }
        end

        if sg[:egress]
          sg[:egress].sort_by! { |x| x.to_s }
        end

        if local_sg[:egress]
          local_sg[:egress].sort_by! { |x| x.to_s }
        end
        diff = HashDiff.diff(sg, local_sg)
      end

      def update_vars(hash=@_local_sg)
        hash.each do |k, v|
          if v.is_a?(String)
            if /\<\%(.*)\%\>/.match(v)
              var_keys = /\<\%(.*)\%\>/.match(v).captures
              if Demeter::vars.has_key?(var_keys[0].strip)
                hash[k] = Demeter::vars[var_keys[0].strip]
                if hash[k].is_a?(Array)
                  extended = []
                  hash[k].each do |value|
                    h1 = hash.clone
                    h1[k] = value
                    extended << h1
                  end
                  hash = extended
                end
              else
                fail "Key #{v} not found!"
              end
            end
          elsif v.is_a?(Hash)
            hash[k] = update_vars v
          elsif v.is_a?(Array)
            tmp = []
            v.flatten.each do |x| 
              if x.is_a?(Hash)
                tmp << update_vars(x)
              end
            end
            hash[k] = tmp.flatten
          end
        end
        hash
      end

      def create
        if @_sg.empty?
          # update variables
          local_sg = update_vars(@_local_sg)
          # update once again to replace deep variable links
          local_sg = update_vars(@_local_sg)

          resp = @ec2.create_security_group({
            group_name: local_sg[:name],
            description: local_sg[:description], # required
            vpc_id: local_sg[:vpc_id]
          })

          @ec2.create_tags(:resources => [resp.group_id], :tags => [
            { :key => 'Name', :value => local_sg[:name] }
          ])

          puts "Created SG: #{local_sg['name']} (#{resp.group_id})"
          true
        end
      end

      def modify
        the_diff = diff
        pluses = the_diff.select { |s| s[0] == "+" }
        minuses = the_diff.select { |s| s[0] == "-" }
        pluses.each do |plus|
          next if plus[1] == "description"
          values = plus[2]
          if values.has_key?(:cidr_block)
            if plus[1].include?('ingress') 
              @ec2.authorize_security_group_ingress({
                group_id: group_id,
                ip_protocol: values[:protocol],
                from_port: values[:from_port],
                to_port: values[:to_port],
                cidr_ip: values[:cidr_block],
              })
            else
              @ec2.authorize_security_group_egress({
                group_id: group_id,
                ip_permissions: [{
                  ip_protocol: values[:protocol],
                  from_port: values[:from_port],
                  to_port: values[:to_port],
                  ip_ranges: [
                    {
                      cidr_ip: values[:cidr_block]
                    }
                  ]
                }]
              })
            end
          elsif values.has_key?(:source_security_group)
            if plus[1].include?('ingress') 
              @ec2.authorize_security_group_ingress({
                group_id: group_id,
                ip_permissions: [{
                  ip_protocol: values[:protocol],
                  from_port: values[:from_port],
                  to_port: values[:to_port],
                  user_id_group_pairs: [{
                    group_id: values[:source_security_group]
                  }]
                }]
              })
            else
              @ec2.authorize_security_group_egress({
                group_id: group_id,
                ip_permissions: [{
                  ip_protocol: values[:protocol],
                  from_port: values[:from_port],
                  to_port: values[:to_port],
                  user_id_group_pairs: [{
                    group_id: values[:source_security_group]
                  }]
                }]
              })
            end
          end
        end
        minuses.each do |minus|
          values = minus[2]
          if values.has_key?(:cidr_block)
            if minus[1].include?('ingress') 
              @ec2.revoke_security_group_ingress({
                group_id: group_id,
                ip_protocol: values[:protocol],
                from_port: values[:from_port],
                to_port: values[:to_port],
                cidr_ip: values[:cidr_block],
              })
            else
              @ec2.revoke_security_group_egress({
                group_id: group_id,
                ip_permissions: [{
                  ip_protocol: values[:protocol],
                  from_port: values[:from_port],
                  to_port: values[:to_port],
                  ip_ranges: [
                    {
                      cidr_ip: values[:cidr_block]
                    }
                  ]
                }]
              })
            end
          elsif values.has_key?(:source_security_group)
            if minus[1].include?('ingress') 
              @ec2.revoke_security_group_ingress({
                group_id: group_id,
                ip_permissions: [{
                  ip_protocol: values[:protocol],
                  from_port: values[:from_port],
                  to_port: values[:to_port],
                  user_id_group_pairs: [{
                    group_id: values[:source_security_group]
                  }]
                }]
              })
            else
              @ec2.revoke_security_group_egress({
                group_id: group_id,
                ip_permissions: [{
                  ip_protocol: values[:protocol],
                  from_port: values[:from_port],
                  to_port: values[:to_port],
                  user_id_group_pairs: [{
                    group_id: values[:source_security_group]
                  }]
                }]
              })
            end
          end
        end
      end
    end
  end
end
