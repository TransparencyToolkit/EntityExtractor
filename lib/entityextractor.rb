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
  def extractALLCAPS(minchar)
    @input.each do |i|
      addlist = Array.new
      parseALLCAPS(i[@extractfield].to_s, i, minchar, addlist)
    end
  end

  # Parses terms in all caps
  def parseALLCAPS(toParse, i, minchar, addlist)
    if toParse =~ (/[A-Z]#{minchar}/)
      index = toParse =~ (/[A-Z]#{minchar}/)
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
      puts toParse[index..charnum]
      addlist.push(toParse[index..charnum])
      parseALLCAPS(toParse.split(toParse[0..charnum], 1), i, minchar, addlist)
      
    # If there are no (more) results, append addlist to JSON
    else
      i["extract"] = addlist
      @output.push(i)
    end
  end

  # Generates JSON output
  def genJSON
    JSON.pretty_generate(@output)
  end

  # TODO:
  # Fix getting multiple all caps terms
  # Get just list of terms by number of occurrence
  # Ignore terms field
end

