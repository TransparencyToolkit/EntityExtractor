require 'json'
load 'extract_set_terms.rb'

class EntityExtractor
  def initialize(input, extract_from, save_field)
    @input = JSON.parse(input)
    @extract_from = extract_from
    @save_field = save_field

    @output = Array.new
  end

  # Extracts set terms
  def extractSetTerms(to_extract, extract_term_fields, case_sensitive)
    @input.each do |item|
      extract = ExtractSetTerms.new(item, @extract_from, to_extract, extract_term_fields, case_sensitive, @save_field)
      @output.push(extract.extractTerms)
    end
  end

  # Gets all results in output
  def getAllOutput
    JSON.pretty_generate(@output)
  end

  # Gets only the results for which terms were found/extracted
  def getOnlyMatching
    matches = @output.select { |item| !item[@save_field].empty? }
    JSON.pretty_generate(matches)
  end

  # Gets a list of the extracted terms by how often they occur
  def getTermList
    counthash = Hash.new{0}

    # Increments for each occurrence of term
    @output.each do |item|
      item[@save_field].each do |term|
        counthash[term] += 1
      end
    end

    # Return hash sorted by value
    return Hash[counthash.sort_by { |k, v| v}]
  end
end
