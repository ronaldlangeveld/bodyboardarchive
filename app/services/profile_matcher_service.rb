class ProfileMatcherService
  def self.match_user_to_profile(user)
    new(user).match
  end

  def self.find_potential_matches(user, limit = 5)
    new(user).find_multiple_matches(limit)
  end

  def initialize(user)
    @user = user
  end

  def match
    return if @user.profile.present? # User already has a profile
    return if @user.name.blank? # No name to match against

    # Try exact match first
    profile = find_exact_match || find_fuzzy_match

    if profile
      assign_profile_to_user(profile)
      profile
    end
  end

  def find_match_without_assignment
    return if @user.profile.present? # User already has a profile
    return if @user.name.blank? # No name to match against

    # Try exact match first, then fuzzy match
    find_exact_match || find_fuzzy_match
  end

  def find_multiple_matches(limit = 5)
    return [] if @user.profile.present? # User already has a profile
    return [] if @user.name.blank? # No name to match against

    matches = []
    
    # First, try exact matches
    exact_matches = find_all_exact_matches
    matches.concat(exact_matches)
    
    # If we need more matches, add fuzzy matches
    if matches.length < limit
      remaining_limit = limit - matches.length
      fuzzy_matches = find_all_fuzzy_matches.reject { |profile| matches.include?(profile) }
      matches.concat(fuzzy_matches.first(remaining_limit))
    end
    
    matches.first(limit)
  end

  private

  def find_exact_match
    # Split user name into parts for matching
    name_parts = normalize_name(@user.name).split
    return if name_parts.length < 2

    first_name = name_parts.first
    last_name = name_parts.last

    # Try exact match on first + last name
    Profile.where(
      "LOWER(first_name) = ? AND LOWER(last_name) = ?",
      first_name.downcase,
      last_name.downcase
    ).where(user: nil).first
  end

  def find_all_exact_matches
    # Split user name into parts for matching
    name_parts = normalize_name(@user.name).split
    return [] if name_parts.length < 2

    first_name = name_parts.first
    last_name = name_parts.last

    # Try exact match on first + last name
    Profile.where(
      "LOWER(first_name) = ? AND LOWER(last_name) = ?",
      first_name.downcase,
      last_name.downcase
    ).where(user: nil).to_a
  end

  def find_fuzzy_match
    # Try matching against import_name for broader matching
    normalized_user_name = normalize_name(@user.name)
    
    Profile.where(user: nil).find do |profile|
      next unless profile.import_name.present?
      
      normalized_profile_name = normalize_name(profile.import_name)
      names_similar?(normalized_user_name, normalized_profile_name)
    end
  end

  def find_all_fuzzy_matches
    # Try matching against import_name for broader matching
    normalized_user_name = normalize_name(@user.name)
    matches = []
    
    Profile.where(user: nil).each do |profile|
      next unless profile.import_name.present?
      
      normalized_profile_name = normalize_name(profile.import_name)
      if names_similar?(normalized_user_name, normalized_profile_name)
        matches << profile
      end
    end
    
    # Sort by similarity score (for now, just return them)
    matches
  end

  def normalize_name(name)
    return '' if name.blank?
    
    # Remove common prefixes, suffixes, and special characters
    name.gsub(/\b(Mr\.?|Mrs\.?|Ms\.?|Dr\.?|Prof\.?)\b/i, '')
        .gsub(/\b(Jr\.?|Sr\.?|II|III|IV)\b/i, '')
        .gsub(/[^\w\s]/, ' ')
        .squeeze(' ')
        .strip
  end

  def names_similar?(name1, name2)
    return false if name1.blank? || name2.blank?

    # Split into words and compare
    words1 = name1.downcase.split
    words2 = name2.downcase.split

    return false if words1.length < 2 || words2.length < 2

    # Check if first and last names match (allowing for middle names)
    first_matches = words1.first == words2.first
    last_matches = words1.last == words2.last

    first_matches && last_matches
  end

  def assign_profile_to_user(profile)
    profile.update!(user: @user)
    Rails.logger.info "Matched user #{@user.email} to profile #{profile.username}"
  end
end