require_relative './spec_helper'
require 'demeter/aws/security_group'

describe Demeter::Aws::SecurityGroup do
    describe '::initialize()' do
    context 'with aws security group' do
      let(:ec2) { 
        Ec2Stub.describe_with_security_groups
      }
      let(:security_group_hash) { {name: 'ec2::infra::project', description: 'Demeter'} }
      let(:security_group) { Demeter::Aws::SecurityGroup.new(ec2) }
      let(:load_path) { File.expand_path(File.join(__dir__, "projects/with_vars/ec2_apollo.yml")) }
      let(:vars_path) { File.expand_path(__dir__) }

      it 'loads security group from aws result' do
        sg = ec2.describe_security_groups(filters: [
          {name: "group-name", values: ["ec2::infra/apollo::web"]}
        ]).security_groups.first

        result = security_group.load_aws(sg)
        expect(result).to eq(true)
        expect(security_group.group_name).to eq("ec2::infra/apollo::web")
      end   
      
      it 'load_aws with the vars set' do
        sg = ec2.describe_security_groups(filters: [
          {name: "group-name", values: ["ec2::infra/apollo::web"]}
        ]).security_groups.first
        security_group.load_aws(sg)
        my_project = security_group.project_key
        expect(Demeter::vars).to include("security_group.#{my_project}.id")
      end

      it 'replaces configs with vars' do
        sg = ec2.describe_security_groups(filters: [
          {name: "group-name", values: ["ec2::infra/apollo::web"]}
        ]).security_groups.first
        security_group.load_aws(sg)
        expect(security_group.diff).to eq([
          ["-", "egress", [
            {:protocol=>"-1", :from_port=>0, :to_port=>0, :cidr_block=>"0.0.0.0/0"}
          ]],
          ["-", "ingress", [
            {:protocol=>"tcp", :from_port=>22, :to_port=>22, :cidr_block=>"10.0.0.0/8"},
            {:protocol=>"tcp", :from_port=>22, :to_port=>22, :cidr_block=>"10.10.0.0/24"},
            {:protocol=>"tcp", :from_port=>22, :to_port=>22, :source_security_group=>"sg-11111"}
          ]],
        ])
      end

      it 'replaces array config vars' do
        Demeter::root(vars_path)
        project_config = YAML::load_file(load_path)
        security_group.load_local(project_config['security_groups'].first)
        diffs = security_group.diff
        vpcone = diffs.detect { |d| d[1] == "vpc_id" }
        cidrs = diffs.detect { |s| s[2].is_a?(Array) && !s[2].empty? && s[2].first.has_key?(:cidr_block) }
        expect(cidrs[2].size).to eq(7)
      end

      it 'replaces array config vars with update_vars' do
        Demeter::root(vars_path)
        project_config = YAML::load_file(load_path)
        security_group.load_local(project_config['security_groups'].first)
        updated_hash = security_group.update_vars
        expect(updated_hash[:ingress].size).to eq(7)
      end
    end
  end 
end



