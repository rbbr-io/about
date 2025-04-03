require 'favicon_get'
require 'open-uri'
require 'fileutils'
require 'nokogiri'
require 'image_size'

namespace :services do
  desc 'Download high-quality logos from service URLs'
  task :download_logos do
    puts "Starting logo download..."

    # Ensure the directory exists
    target_dir = 'public/images/services'
    FileUtils.mkdir_p(target_dir)

    # Read URLs from file
    urls = File.readlines('service_urls.txt').map(&:strip)

    # Min dimensions for a good logo
    MIN_DIMENSION = 64 # Minimum width/height for icons

    # Map of service URLs to filenames expected in the HTML
    service_map = {
      'api2cart' => 'api2cart',
      'apideck' => 'apideck',
      'codat' => 'codat',
      'csvbox' => 'csvbox',
      'easypost' => 'easypost',
      'tryfinch' => 'finch',
      'imgproxy' => 'imgproxy',
      'merge' => 'merge',
      'nango' => 'nango',
      'nylas' => 'nylas',
      'plaid' => 'plaid',
      'redoxengine' => 'redox',
      'rutter' => 'rutter',
      'smartcar' => 'smartcar',
      'tryterra' => 'terra',
      'unified' => 'unified',
      'github' => 'administrate'
    }

    urls.each do |url|
      begin
        puts "Processing #{url}..."

        # Get service name for the filename
        domain = url.gsub(/https?:\/\//, '').gsub(/www\./, '').split('/').first.split('.').first

        # Get the proper service name from the map
        service_name = service_map[domain] || domain

        # Final output path (always PNG)
        output_path = File.join(target_dir, "#{service_name}.png")

        # Get icons with longer timeout to ensure we get all options
        icons = FaviconGet.get(url, timeout: 15)

        if icons.empty?
          puts "No icons found for #{url}"
          next
        end

        # Filter icons to only keep the ones with decent size
        suitable_icons = icons.select do |icon|
          icon.width && icon.height && # Has dimensions
          icon.width >= MIN_DIMENSION && icon.height >= MIN_DIMENSION # Minimum size
        end

        # If none match the minimum size, take the largest available
        icon = if suitable_icons.empty?
                 puts "No large icons found, using the largest available"
                 icons.first
               else
                 suitable_icons.first # They're already sorted by size
               end

        puts "Selected icon: #{icon.url} (#{icon.width}x#{icon.height}, format: #{icon.format})"

        # Download and save icon
        begin
          URI.open(icon.url) do |image|
            # Always save as PNG regardless of source format
            File.open(output_path, "wb") do |file|
              file.write(image.read)
            end
          end
          puts "Logo saved to #{output_path}"
        rescue => e
          puts "Error downloading logo from #{icon.url}: #{e.message}"

          # Try the next icon if available
          if icons.size > 1
            backup_icon = icons[1]
            puts "Trying next icon: #{backup_icon.url}"
            begin
              URI.open(backup_icon.url) do |image|
                File.open(output_path, "wb") do |file|
                  file.write(image.read)
                end
              end
              puts "Backup logo saved to #{output_path}"
            rescue => e
              puts "Error downloading backup logo: #{e.message}"
            end
          end
        end
      rescue => e
        puts "Error processing #{url}: #{e.message}"
      end
    end

    puts "Logo download completed!"
  end

  desc 'Process logos for service cards'
  task :process_logos => :download_logos do
    puts "Processing downloaded logos for service cards..."

    target_dir = 'public/images/services'

    # Check all downloaded logos
    Dir.glob(File.join(target_dir, '*')).each do |file|
      next if File.directory?(file)

      # Check size of image
      begin
        file_content = File.open(file, 'rb').read
        image_size = ImageSize.new(file_content)

        if image_size.width && image_size.height
          puts "Image #{File.basename(file)}: #{image_size.width}x#{image_size.height}"
        end
      rescue => e
        puts "Error checking image size for #{file}: #{e.message}"
      end
    end

    # Verify all expected files exist
    expected_files = %w[
      api2cart.png
      apideck.png
      codat.png
      csvbox.png
      easypost.png
      finch.png
      imgproxy.png
      merge.png
      nango.png
      nylas.png
      plaid.png
      redox.png
      rutter.png
      smartcar.png
      terra.png
      unified.png
      administrate.png
    ]

    missing_files = expected_files.reject { |f| File.exist?(File.join(target_dir, f)) }
    if missing_files.empty?
      puts "All logo files successfully downloaded!"
    else
      puts "Warning: Missing logo files: #{missing_files.join(', ')}"
    end

    puts "Logo processing completed!"
  end
end