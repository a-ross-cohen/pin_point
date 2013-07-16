require 'csv'
require 'net/http'
require 'zip/zipfilesystem'

namespace :pin_point do
  
  task :import => :environment do
    
    TIME = Time.now.to_i
    ZIP_FILE = "/tmp/pin_point_data_#{TIME}.zip"
    BLOCK_FILE = "/tmp/pin_point_block_#{TIME}.csv"
    LOCATION_FILE = "/tmp/pin_point_location_#{TIME}.csv"
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
    
    puts "Dropping existing indexes..."
    
    PinPoint::IpBlock.remove_indexes
    
    puts "Generating new indexes..."
    
    PinPoint::IpBlock.create_indexes
    
    puts "Importing IP Block data. This will take a while..."
    
    import_start = ip_block_start = Time.now
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
          if ($. - 2) % 100000 == 0
            now = Time.now
            current_count = ($. - 2)
            per_second = ($. - 2) / ( ( now - ip_block_start ) / 1.second )
            seconds = ( now - ip_block_start ) % 1.minute
            minutes = ( now - ip_block_start ) / 1.minute
            puts "%d blocks imported in %d minutes, %d seconds. %.2f blocks/s ..." % [ current_count, minutes, seconds, per_second ]
          end
        end
      end
    end
    
    puts "Mapping location data to IP Blocks..."
    
    location_start = Time.now
    open LOCATION_FILE, 'r' do |file|
      while line = file.gets
        if $. > 2
          begin
            row = CSV.parse_line( line.force_encoding('UTF-8').chars.select{|i| i.valid_encoding?}.join, col_sep: ',' )
          rescue CSV::MalformedCSVError
            Rails.logger.debug "Failed to parse: #{line}\n#{$!.message}"
          else
            PinPoint::IpBlock.where( location: row[0].to_i ).update_all({
              country: row[1],
              state: row[2],
              city: row[3],
              coordinates: [row[6].to_f, row[5].to_f]
            })
          end
          if ($. - 2) % 100000 == 0
            now = Time.now
            current_count = ($. - 2)
            per_second = ($. - 2) / ( ( now - location_start ) / 1.second )
            seconds = ( now - location_start ) % 1.minute
            minutes = ( now - location_start ) / 1.minute
            puts "%d locations mapped in %d minutes, %d seconds. %.2f locations/s ..." % [ current_count, minutes, seconds, per_second ]
          end
        end
      end
    end
    
  end
  
end
