require 'treat'
include Treat::Core::DSL
require 'date'
require 'json'
require 'american_date'

class ExtractDates
  def initialize(text)
    @text = text
    @output = Array.new
  end
  
  def chunk(append)
    if !@text.empty?
      i = @text
      s = paragraph(i).segment
      s.each do |j|
        dateExtract(j, append, j, i)
      end
    end
    
    return @output
  end

  # Finds matches for date formats in the blob from chunk(append)
  def dateExtract(blob, append, title, description)
    blobstring = blob.to_s
    
    begin
      # See below, but with yyyy-mm-dd (and months can only start with 0-1
      if blobstring.match(/(?:19|20)\d{2}(?:-|\/)[0-1]?[0-9](?:-|\/)[0-3]?[0-9]/)
        save = Regexp.last_match.to_s
        saveparse = save.gsub("-", "/") # Needed for american_date gem
        addItem(Date.parse(saveparse).to_s, append, title, description, blobstring, save)

        # mm-dd-yyyy, mm/dd/yy, and similar. m or d must start with 0-3 (optional) and end in not 0
        # Year can only start with 19 or 20 if it is four chars, or it could be 2 char
      elsif blobstring.match(/[0-3]?[0-9](?:-|\/)[0-3]?[0-9](?:-|\/)(?:(?:19|20)\d{2}|\d{2})/)
        save = Regexp.last_match.to_s
        saveparse = save.gsub("-", "/")
        addItem(Date.parse(saveparse).to_s, append, title, description, blobstring, save)

        # Same as below but with dd before instead of in middle and supports two digit year
        # Matches: dd Month yyyy, ddth Month yyyy, ddmonthyy ddthmonthyyyy   
      elsif blobstring.match(/(?:(?:[0-3]?[0-9])(?:st|nd|rd|th)?) *(?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Nov(?:ember)?|Dec(?:ember)?) *(?:19|20)?\d{2}/i)
        save = Regexp.last_match.to_s
        addItem(Date.parse(save).to_s, append, title, description, blobstring, save)
    
        # Matches: Month yyyy, Month dd yyyy, Month ddth yyyy, Month dd, yyyy, Month ddth, yyyy,
        # Month can be full month or abbreviation, optional dd with 1 optional th/st/nd/rd, yyyy starting in 19 or 20
        # Case insensitive, optional/variable spaces
      elsif blobstring.match(/(?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Nov(?:ember)?|Dec(?:ember)?) *(?:(?:[0-3]?[0-9])(?:st|nd|rd|th)?)?,? *(?:19|20)\d{2}/i)
        save = Regexp.last_match.to_s
        addItem(Date.parse(save).to_s, append, title, description, blobstring, save)

        # Matches: yyyy
        # Must start and end with word boundry, year must start with 19 or 20 and be 4 numbers
      elsif blobstring.match(/\b(?:19|20)\d{2}\b/)
        save = Regexp.last_match.to_s
        addItem(Date.parse(Date.new(save.to_i).to_s), append, title, description, blobstring, save)
      end

    rescue
    end
  end

  # Adds and item to the hash
  def addItem(date, append, title, description, blob, regex)
    shash = Hash.new
    shash[:parsed_date] = date
    shash[:raw_date] = regex
    shash[:short_chunk] = title
    
    # Append fields specified
    unless append == {nil=>nil}
      append.each do |k, v|
        shash[k] = v
      end
    end

    flag = 0
    @output.each do |o|
      if (o[:parsed_date] == shash[:parsed_date]) && (o[:short_chunk].to_s == shash[:short_chunk].to_s)
        flag = 1
        break
      end
    end

    if flag == 0
      @output.push(shash)
    end

    blob.slice! regex
    dateExtract(blob, append, title, description)
  end
end

