require 'csv'
require 'net/http'
require 'zip/zipfilesystem'

namespace :pin_point do
  
  task :import => :environment do
    
    TIME = Time.now.to_i
    ZIP_FILE = "/tmp/pin_point_data_#{TIME}.zip"
    BLOCK_FILE = "/tmp/pin_point_block_#{TIME}.zip"
    LOCATION_FILE = "/tmp/pin_point_location.zip"
    REMOTE_DATA_DOMAIN = 'geolite.maxmind.com'
    REMOTE_DATA_PATH = '/download/geoip/database/GeoLiteCity_CSV/GeoLiteCity-latest.zip'
    
    puts "Sourcing data..."
    
    Net::HTTP.start REMOTE_DATA_DOMAIN do |http|
      response = http.get REMOTE_DATA_PATH
      open ZIP_FILE, 'wb' do |file|
        file.write response.body
      end
    end
    
    puts "Unzipping..."
    
    Zip::ZipFile.open ZIP_FILE do |zipfile|
      zipfile.each do |file|
        case file.name
        when /block/i
          zipfile.extract file.name, BLOCK_FILE
        when /location/i
          zipfile.extract file.name, LOCATION_FILE
        end
      end
    end
    
    puts "Removing old IP Block data..."
    
    PinPoint::IpBlock.delete_all
    
    puts "Importing IP Block data. This will take a while..."
    
    open BLOCK_FILE, 'r' do |file|
      while line = file.gets
        if $. > 2
          begin
            row = CSV.parse_line( line.force_encoding('UTF-8').chars.select{|i| i.valid_encoding?}.join, col_sep: ',' )
          rescue CSV::MalformedCSVError
            Rails.logger.debug "Failed to parse: #{line}\n#{$!.message}"
          else
            PinPoint::IpBlock.create({
              range_low: row[0].to_i,
              range_high: row[1].to_i,
              location: row[2].to_i
            })
          end
          puts "#{($. - 2)} blocks imported..." if ($. - 2) % 100000 == 0
        end
      end
    end
    
    puts "Mapping location data to IP Blocks..."
    
    open LOCATION_FILE, 'r' do |file|
      while line = file.gets
        if $. > 2
          begin
            row = CSV.parse_line( line.force_encoding('UTF-8').chars.select{|i| i.valid_encoding?}.join, col_sep: ',' )
          rescue CSV::MalformedCSVError
            Rails.logger.debug "Failed to parse: #{line}\n#{$!.message}"
          else
            block = PinPoint::IpBlock.where( location: row[0].to_i ).update_all({
              country: row[1],
              state: row[2],
              city: row[3],
              coordinates: [row[6].to_f, row[5].to_f]
            })
          end
          puts "#{($. - 2)} locations mapped..." if ($. - 2) % 10000 == 0
        end
      end
    end
    
  end
  
end
