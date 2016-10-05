require 'pathname'
require 'zlib'
require 'base64'
require 'json'

Facter.add('hiera_data') do
  hiera_data_path = Pathname.new '/etc/hiera'

  hiera_data = {}
  hiera_data_path.find do |path|
    next unless path.to_s.end_with? '.yaml'
    next unless path.readable?
    name = path.relative_path_from(hiera_data_path).sub_ext('').to_s
    begin
      data = path.read
    rescue StandardError => exception
      puts "Could not read the file: #{path}: #{exception}"
      next
    end
    hiera_data.store name, data
  end

  begin
    hiera_data = Base64.strict_encode64 Zlib::Deflate.deflate(JSON.dump(hiera_data), Zlib::BEST_COMPRESSION)
  rescue StandardError => exception
    puts "Could not encode the Hiera data: #{exception}"
    hiera_data = nil
  end

  setcode do
    hiera_data
  end
end
