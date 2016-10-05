require 'facter'
require 'hiera'

# This fact is being used to set the node's environment in the Foreman
# using the Foreman's feature:
#
# update_environment_from_facts
# If Foreman receives an environment fact from one of its hosts and if this option is true,
# it will update the host’s environment with the new value. By default this is not the case as
# Foreman should manage the host’s environment. Default: false
#

Facter.add('environment') do
  default_environment = 'production'

  hiera_config = lambda do
    %w(
    /etc/puppet/hiera.yaml
    /etc/hiera.yaml
    ).find do |file|
      File.readable? file
    end
  end

  hiera_object = lambda do |config|
    Hiera.new(config: config)
  end

  process_environment = lambda do |environment|
    environment.gsub /\W/, '_'
  end

  lookup_environment = lambda do |hiera|
    fuel_plugin_lcm = hiera.lookup 'fuel-plugin-lcm', [], {}, {}, :priority
    break default_environment unless fuel_plugin_lcm.is_a? Hash
    fuel_plugin_lcm.fetch 'node_env', default_environment
  end

  setcode do
    config = hiera_config.call
    break default_environment unless config
    hiera = hiera_object.call config
    break default_environment unless hiera
    environment = lookup_environment.call hiera
    break default_environment unless environment
    process_environment.call environment
  end
end
