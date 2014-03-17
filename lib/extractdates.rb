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
  
  def chunk(file)
    if @text
      begin
        c = @text.chunk
        c.each do |i|
          s = paragraph(i).segment
          dateExtract(s)
          s.each do |j|
            shash = Hash.new
            shash[:date] = dateExtract(j)
            if shash[:date]
              shash[:file] = file
              shash[:title] = j
              shash[:description] = i
              @output.push(shash)
            end
          end
        end
      rescue
      end
    end
    return @output
  end

  def dateExtract(blob)
    # Date formats-
      # mm/dd/yy
      # mm/dd/yyyy
      # Month dd, yyyy
      # Month ddth, yyyy
      # Month yyyy

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
end

