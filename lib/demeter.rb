require 'demeter/version'

module Demeter
  DEFAULT_ENV = 'development'.freeze

  def self.root(root=nil)
    if root
      @root ||= root
    else
      @root ||= Pathname.new(Dir.pwd)
    end
  end

  def self.env
    @environment ||= ENV['DEMETER_ENV'] || ENV['ENV'] || DEFAULT_ENV 
  end
  
  def self.vars
    @vars ||= begin
      global_vars = {}
      env_vars = {}
      global_path = File.join(Demeter::root, "/variables/global.yml")
      environment_path = File.join(Demeter::root, "/variables/#{self.env}.yml")

      if File.exists?(global_path)
        global_vars = YAML::load_file(global_path)
        global_vars = Hash[global_vars.map{|k,v| ["global.#{k}",v]}]
      else
        fail "Global file /variables/global.yml not found! Add it before rerunning..."
      end

      if File.exists?(environment_path)
        env_vars = YAML::load_file(environment_path)
        env_vars = Hash[env_vars.map{|k,v| ["env.#{k}",v]}]
      else
        fail "Environment file /variables/#{Demeter::env}.yml not found! Add it before rerunning..."
      end

      global_vars.merge!(env_vars)
    end
  end

  def self.set_var(key, value)
    vars = self.vars
    vars[key] = value
    @vars = vars
  end
end
