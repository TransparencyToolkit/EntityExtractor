require 'treat'
include Treat::Core::DSL
require 'uploadconvert'
require 'date'
require 'json'
require 'american_date'

class ExtractDates
  def initialize(text)
    @text = text
    @output = Array.new
  end
  
  def chunk
    c = @text.chunk
    c.each do |i|
      s = paragraph(i).segment
      dateExtract(s)
      s.each do |j|
        shash = Hash.new
        shash[:date] = dateExtract(j)
        if shash[:date]
          shash[:title] = j
          shash[:description] = i
          @output.push(shash)
        end
      end
    end
  end

  def dateExtract(blob)
    # TOADD: 
      # Multiple dates
      # Year detection
      # Conditional American dates
      # Time ranges
      # Filtering

    begin
      return DateTime.parse(blob).to_s
    rescue
    end
  end

  # Hook into entity extractor
     # Input
     # Output JSON
     # Append

  # Generate new JSON
  def genJSON
    # Add support for doc info
    JSON.pretty_generate(@output)
  end

  # Return array to append to item
  def genAppend
    
  end
end

u = UploadConvert.new("file.pdf")
intext = u.detectPDFType
e = ExtractDates.new(intext)
e.chunk
puts e.genJSON
