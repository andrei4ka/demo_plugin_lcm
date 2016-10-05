require 'json'
require 'yaml'

Facter.add('hiera_hierarchy') do
  hiera_config_file = '/etc/puppet/hiera.yaml'
  hiera_config_file = '/etc/hiera.yaml' unless File.exists? hiera_config_file
  break nil unless File.exists? hiera_config_file

  begin
    data = YAML.load_file hiera_config_file
    fail 'Hiera config should contain a Hash' unless data.is_a? Hash
  rescue StandardError => exception
    puts "Could not load the Hiera config: #{hiera_config_file}: #{exception}"
    break nil
  end

  hierarchy = data.fetch :hierarchy, nil

  setcode do
    JSON.dump hierarchy
  end
end
