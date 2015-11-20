require_relative './spec_helper'
require_relative 'ec2_stub'
require 'demeter/aws/manage_security_groups'
require 'demeter/aws/security_group'
require 'demeter'

describe Demeter::Aws::ManageSecurityGroups do
  describe '::describe' do

    context 'with an existing aws SG and a local file' do
      let(:ec2) do 
        Ec2Stub.describe_with_security_groups
      end 

      let(:load_path) { File.expand_path(File.join(__dir__, "projects/simple/*.yml")) }
      let(:vars_path) { File.expand_path(__dir__) }
      let(:smanage) { Demeter::Aws::ManageSecurityGroups.new(ec2:ec2, project_path:load_path) }

      it 'loads both aws and local file' do
        Demeter.root(vars_path)
        result = smanage.describe
        expect(result).to_not eq(nil)
      end

      it 'shows the diff with both aws and local file' do
        all_diffs = smanage.diff_all
      end

    end

    context 'with non-existing aws SG and a local file' do
      let(:ec2) do 
        Ec2Stub.describe_with_no_groups
      end
      let(:load_path) { File.expand_path(File.join(__dir__, "projects/simple/**/*.yml")) }
      let(:smanage) { Demeter::Aws::ManageSecurityGroups.new(ec2:ec2, project_path:load_path) }

      it 'creates the new security group' do
        allow(ec2).to receive(:create_security_group).and_return(double('ec2_response', group_id: "sg-12345"))
        smanage.create_all
        expect(ec2).to have_received(:create_security_group)
      end
      
      it 'has no diffs' do
        the_diff = smanage.diff_all                                                                                                                           
        pluses = the_diff.select { |s| s[0] == "+" }                                                                                                          
        minuses = the_diff.select { |s| s[0] == "-" }                                                                                                         
        expect(minuses.size).to eq(0)                                                                                                                         
        expect(pluses.size).to eq(0)                                                                                                                          
      end

    end

    context 'with different config in the local file than exists in aws' do
      let(:ec2) do 
        Ec2Stub.describe_with_security_groups
      end
      let(:load_path) { File.expand_path(File.join(__dir__, "projects/simple/ec2_apollo.yml")) }
      let(:smanage) { Demeter::Aws::ManageSecurityGroups.new(ec2:ec2, project_path:load_path) }

      it 'removes source security group and adds cidr block' do
        the_diff = smanage.diff_all                                                                                                                           
        pluses = the_diff[the_diff.keys.first].select { |s| s[0] == "+" }
        minuses = the_diff[the_diff.keys.first].select { |s| s[0] == "-" }
        expect(minuses.size).to eq(1)
        expect(pluses.size).to eq(1)
      end
    end

  end

end
