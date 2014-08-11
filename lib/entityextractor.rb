require 'json'
load 'extractdates.rb'
load 'handleinput.rb'
require 'uploadconvert'

class EntityExtractor
  def initialize(input, fieldoutname, *extractfield)
    @input = JSON.parse(input)
    @fieldoutname = fieldoutname
    @extractfield = *extractfield
    @output = Array.new
  end

  # Extract terms input from preset list
  def extractTerms(extractlist, i, addlist, field)
    count = 0
    downcased = i[field].to_s.downcase
      
    # Check the item for each term
    extractlist.each do |t, c|
      count+=1
      if c == true
        if i[field].to_s.include? t
          addlist.push(t)
        end
      else
        if downcased.include? t.downcase
          addlist.push(t)
        end
      end
    end
  end

  # Parses terms in all caps
  def parseALLCAPS(toParse, i, minchar, addlist, ignoreterms, savefield, extractfield)
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
      parseALLCAPS(toParse, i, minchar, addlist, ignoreterms, savefield, extractfield)

    # If there are no (more) results, append addlist to JSON
    else
      i[extractfield] = savefield
    end
  end

  # Get list of just extracted terms by occurrence
  def getExtract
    extracthash = Hash.new
    
    # Generate hash of all extracted terms
    @output.each do |i|
      i[@fieldoutname].each do |e|
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

  def extract(type, minchar, ignoreterms, terms, ignorefields, caseinfo, mapto)
    flag = 0
   
    h = HandleInput.new(terms, ignorefields, caseinfo)
    extractlist = h.detecttype

    @input.each do |i|
      if i.length == 2
        i = @input
        flag = 1
      end

      addlist = Array.new
      
      # Generate set terms list
      if type == "set"
        @extractfield.each do |f|
          extractTerms(extractlist, i, addlist, f)
        end
        
        if mapto
          i[@fieldoutname] = h.mapout(addlist, mapto)
        else
          i[@fieldoutname] = addlist
        end
        @output.push(i)
      
      # Generate ALLCAPS terms list
      elsif type == "ALLCAPS"
        @extractfield.each do |f|
          savefield = i[f].to_s + " "
          parseALLCAPS(i[f].to_s, i, minchar, addlist, ignoreterms, savefield, f)
        end
        
        i[@fieldoutname] = addlist
        @output.push(i)

      # Extract dates
      elsif type == "date"
        @extractfield.each do |f|
          d = ExtractDates.new(i[f])
          outhash = d.chunk(i["path"])
          @output.push(outhash)
        end

      # Extract both set terms and ALLCAPS
      elsif type == "both"
        @extractfield.each do |f|
          savefield = i[f].to_s + " "
          parseALLCAPS(i[f].to_s, i, minchar, addlist, ignoreterms, savefield, f)
          extractTerms(extractlist, i, addlist, f)
        end

        if mapto
          i[@fieldoutname] = h.mapout(addlist, mapto)
        else
          i[@fieldoutname] = addlist
        end

        @output.push(i)
      end

      if flag == 1
        break
      end
    end 
 end
end

