class ExtractSetTerms
  def initialize(item, extract_field, to_extract, extract_term_fields, case_sensitive, save_field)
    @item = item
    @extract_field = extract_field

    @to_extract = JSON.parse(to_extract)
    @extract_term_fields = extract_term_fields
    @case_sensitive = case_sensitive

    @extract_dict = Hash.new
    @save_field = save_field
    @item_out = item
  end

  # Gets a list of terms to extract
  def processHashInput
    # Go through each item then each field
    @to_extract.each do |ex_key, ex_value|
      ex_value.each do |ex_field, ex_term|
        
        # Check if it is the right field
        if ex_field == @extract_term_fields || @extract_term_fields.include?(ex_field)
          # Make dictionary of terms to extract and overall mapping
          ex_term.is_a?(Array) ? processArrayInput(ex_term, ex_key) : @extract_dict[term] = ex_key
        end

      end
    end
  end

  # Add all items in array to dictionary of terms to extract
  def processArrayInput(extract_arr, map_val)
    extract_arr.each do |term| 
      map_val = term if map_val == nil
      @extract_dict[term] = map_val
    end
  end

  # Check if the term appears in the text
  def matchTerm?(term, text, case_sensitive)
    # Downcase term and text if not case sensitive
    if case_sensitive == false
      term = term.downcase
      text = text.downcase
    end
    
    # Return if it maches
    if text.to_s.match(/\b(#{term})\b/)
      return true
    end
  end

  # Check if item is case sensitive
  def isCaseSensitive?(term)
    if @case_sensitive == "case-sensitive"
      return true
    elsif @case_sensitive == "case-insensitive"
      return false
    else
      # Handle item by item variations
      is_case_sensitive = @to_extract[term[1]][@case_sensitive]
      if is_case_sensitive == "Yes"
        return true 
      else return false
      end
    end
  end

  # Process input list and go through all terms and fields
  def extractTerms
    # Process input list
    @to_extract.is_a?(Hash) ? processHashInput : processArrayInput(@to_extract, nil)
    @item_out[@save_field] = Array.new

    # Go through each term and field to check for matches
    @extract_dict.each do |term|
      item_case_sensitivity = isCaseSensitive?(term)
      @extract_field.each do |field|

        # Add to list of terms if it matches
        if matchTerm?(term[0], @item[field], item_case_sensitivity)
          @item_out[@save_field].push(term[1])
        end

      end
    end

    # Deduplicate and return
    @item_out[@save_field].uniq!
    return @item_out
  end
end
