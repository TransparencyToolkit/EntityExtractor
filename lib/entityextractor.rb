require 'json'

class EntityExtractor
  def initialize(input, extractfield)
    @input = JSON.parse(input)
    @extractfield = extractfield
    @output = Array.new
  end

  # Extract terms input from preset list
  def extractTerms(*terms)
    @input.each do |i|
      addlist = Array.new
      count = 0
      
      # Check the item for each term
      terms.each do |t|
        count+=1
        if i[@extractfield].to_s.include? t
          addlist.push(t)
          
          # Add found terms to output on last term
          if count == terms.length
            i["extract"] = addlist
            @output.push(i)
          end

        elsif count == terms.length
          i["extract"] = addlist
          @output.push(i)
        end
      end
    end
  end

  # Extract all terms in ALLCAPS (specifiy min num CAPS chars in row)
  def extractALLCAPS(minchar, ignoreterms)
    @input.each do |i|
      addlist = Array.new
      parseALLCAPS(i[@extractfield].to_s, i, minchar, addlist, ignoreterms)
    end
  end

  # Parses terms in all caps
  def parseALLCAPS(toParse, i, minchar, addlist, ignoreterms)
    if toParse =~ (/[A-Z]{#{minchar}}/)
      index = toParse =~ (/[A-Z]{#{minchar}}/)
      charnum = 0

      # Find word in all caps
      toParse.each_char do |c|
        if charnum >= index
          if toParse[c] == toParse[c].upcase && toParse[c] !~ (/[[:punct:]]/) && toParse[c] !~ (/[[:digit:]]/)
            charnum += 1
          else break
          end
        else
          charnum += 1
        end
      end

      # Remove any extra characters
      if toParse[charnum-2] == " "
        charnum = charnum-3
      elsif toParse[charnum-1] == " "
        charnum = charnum-2
      else charnum = charnum-1
      end
      
      # Filter out terms in ignoreterms array
      if !(ignoreterms.include? toParse[index..charnum])
        addlist.push(toParse[index..charnum])
      end

      parsedstring = toParse[0..charnum]
      toParse.slice! parsedstring
      parseALLCAPS(toParse, i, minchar, addlist, ignoreterms)

    # If there are no (more) results, append addlist to JSON
    else
      i["extract"] = addlist
      @output.push(i)
    end
  end

  # Get list of just extracted terms by occurrence
  def getExtract
    extracthash = Hash.new
    
    # Generate hash of all extracted terms
    @output.each do |i|
      i["extract"].each do |e|
        if extracthash.has_key? e
          extracthash[e] += 1
        else
          extracthash[e] = 1
        end
      end
    end
    
    # Sort hash
    return Hash[extracthash.sort_by { |k, v| v}]
  end

  # Generates JSON output
  def genJSON
    JSON.pretty_generate(@output)
  end
end
