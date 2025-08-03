require_relative './seeds/sixty40_profiles'

class ProfileImporter
  def self.import
    puts "Starting profile import..."
    puts "Total profiles to import: #{PROFILES.length}"

    success_count = 0
    error_count = 0
    skipped_count = 0

    PROFILES.each_with_index do |profile_data, index|
      begin
        # Extract username from profile_url
        username = extract_username(profile_data[:profile_url])
        
        if username.blank?
          puts "Skipping profile #{profile_data[:id]}: No valid username"
          skipped_count += 1
          next
        end

        # Check if profile already exists
        existing_profile = Profile.find_by(username: username)
        if existing_profile
          puts "Profile #{username} already exists, skipping..."
          skipped_count += 1
          next
        end

        # split the full name into first and last names
        full_name = profile_data[:full_name].to_s.strip
        first_name, last_name = full_name.split(' ', 2)

        # Create profile
        profile = Profile.new(
          username: username,
          first_name: first_name,
          last_name: last_name,
          import_name: profile_data[:full_name],
          imported_at: Time.current,
          sixty_forty_import: true, # Assuming all profiles are from Sixty40
          is_rider: true, # Default to rider, can be updated later
          is_photographer: false,
          import_location: profile_data[:location] || 'sixty40',
        )

        # Add nationality if flag exists and is not empty
        if profile_data[:flag].present?
          country = Country.find_by(code: profile_data[:flag])
          if country
            profile.countries << country
          else
            puts "Warning: Country not found for flag '#{profile_data[:flag]}' (Profile: #{username})"
          end
        end

        if profile.save
          success_count += 1
          puts "✓ Imported: #{username} (#{success_count}/#{PROFILES.length})" if (index + 1) % 100 == 0
        else
          puts "✗ Failed to save profile #{username}: #{profile.errors.full_messages.join(', ')}"
          error_count += 1
        end

      rescue => e
        puts "✗ Error importing profile #{profile_data[:id]}: #{e.message}"
        error_count += 1
      end
    end

    puts "\n=== Import Summary ==="
    puts "Total profiles: #{PROFILES.length}"
    puts "Successfully imported: #{success_count}"
    puts "Errors: #{error_count}"
    puts "Skipped: #{skipped_count}"
    puts "====================="
  end

  private

  def self.extract_username(profile_url)
    return nil if profile_url.blank?
    
    # Extract username from URL like '/profile/123/username'
    match = profile_url.match(%r{/profile/\d+/(.+)})
    return nil unless match
    
    username = match[1]
    
    # Clean up username - remove special characters and ensure it's valid
    username = username.gsub(/[^a-zA-Z0-9_-]/, '_') # Replace invalid chars with underscores
    username = username.gsub(/_+/, '_') # Replace multiple underscores with single
    username = username.gsub(/^_|_$/, '') # Remove leading/trailing underscores
    
    # Ensure minimum length
    return nil if username.length < 3
    
    # Truncate if too long
    username = username[0..29] if username.length > 30
    
    username
  end
end

# Run the import
ProfileImporter.import