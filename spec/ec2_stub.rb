class Ec2Stub

  def self.describe_with_security_groups
    Aws::EC2::Client.new(stub_responses: {
      describe_security_groups: { 
        security_groups: [{ 
          group_name: "ec2::infra/apollo::web", 
          group_id: "sg-11111", 
          description: "Managed by Demeter", 
          ip_permissions: [
            { ip_protocol: "tcp", 
              from_port: 22, 
              to_port: 22, 
              user_id_group_pairs: [], 
              ip_ranges: [
                {cidr_ip: "10.0.0.0/8"}, 
                {cidr_ip: "10.10.0.0/24"}
              ], 
              prefix_list_ids: [] 
            }, 
            { ip_protocol: "tcp", 
              from_port: 22, to_port: 22, 
              user_id_group_pairs: [{ user_id: "2222", group_name: nil, group_id: "sg-11111" }], 
              ip_ranges: [], 
              prefix_list_ids: []
            }
          ], 
          ip_permissions_egress: [
            { ip_protocol: "-1", from_port: nil, to_port: nil, user_id_group_pairs: [], ip_ranges: [{cidr_ip: "0.0.0.0/0"}], prefix_list_ids: [] }
          ],
          vpc_id: "vpc-12345", 
          tags: [
            { :key => "Name", :value => "ec2::infra/apollo::web" }
          ]
          }] 
        }
      })
  end

  def self.describe_with_no_groups
    Aws::EC2::Client.new(stub_responses: {
      describe_security_groups: { 
        security_groups: [{ 
          group_name: "does-not-exist", 
          group_id: "sg-111111111", 
          description: "Some things", 
          ip_permissions: [
            { ip_protocol: "tcp", 
              from_port: 22, 
              to_port: 22, 
              user_id_group_pairs: [], 
              ip_ranges: [
                {cidr_ip: "10.0.0.0/8"}, 
                {cidr_ip: "10.10.0.0/24"}
              ], 
              prefix_list_ids: [] 
            }, 
            { ip_protocol: "tcp", 
              from_port: 22, to_port: 22, 
              user_id_group_pairs: [{ user_id: "564673040929", group_name: nil, group_id: "sg-111111111" }], 
              ip_ranges: [], 
              prefix_list_ids: []
            }
          ], 
          ip_permissions_egress: [
            { ip_protocol: "-1", from_port: nil, to_port: nil, user_id_group_pairs: [], ip_ranges: [{cidr_ip: "0.0.0.0/0"}], prefix_list_ids: [] }
          ],
          vpc_id: "vpc-12345", 
          tags: [
            { :key => "Name", :value => "does-not-exist" }
          ]
          }] 
        }
      })
  end

end
