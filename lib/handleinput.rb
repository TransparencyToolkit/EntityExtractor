require 'json'

class HandleInput
  def initialize(json, ignorefields, caseinfo)
    @json = json
    if @ignorefields != nil
      @ignorefields = ignorefields
    else
      @ignorefields = Array.new
    end
    
    @caseinfo = caseinfo
    @output = Array.new
    @outhash = Hash.new
  end

  # Map output to value
  def mapout(addlist, mapto)
    outarr = Array.new
    
    addlist.each do |a|
      if mapto == "key"
        @json.each do |k, v|
          # If it's a nested hash
          if v.is_a? Hash
            # Go through all values
            v.each do |z, w|
              # Check if k is already included
              if !outarr.include? k
                if w == a
                  outarr.push(k)
                end
              end
            end
          else
            # Map for dictionaries
            if !outarr.include? k
              if v == a || k == a
                outarr.push(k)
              end
            end
          end
        end
      else
        @json.each do |k, v|
          v.each do |z, w|
            # Only map if not already matched
            if !outarr.include? v[mapto]
              # Check if vals match
              if w == a
                outarr.push(v[mapto])
              end
            end
          end
        end
      end
    end

    return outarr
  end

  # Figure out which type of input it is: array, hash, hash with hash values
  def detecttype
    if @json.is_a? Array
      @output = @json
      checkCase
    elsif @json.is_a? Hash
      @json.each do |k, v|
        if v.is_a? Hash
          parseValHash
          break
        else
          parseDictionary
          break
        end
      end
    end

    return @outhash
  end

  # Adds case sensitive preferences
  def checkCase
    if @caseinfo == "casesensitive"
      @output.each do |i|
        @outhash[i] = true
      end
    elsif @caseinfo == "noncasesensitive"
      @output.each do |i|
        @outhash[i] = false
      end
    end
  end

  # Handle hashes where the values are a hash
  def parseValHash
    @json.each do |k, v|
      if !@ignorefields.include? "hashkey"
        if @caseinfo.include? "hashkey"
          @outhash[k] = false
        else
          @outhash[k] = true
        end
      end

      v.each do |i, j|
        if !@ignorefields.include? i
          if @caseinfo.include? i
            @outhash[j] = false
          else
            @outhash[j] = true
          end
        end
      end
    end
  end

  # Handle hashes
  def parseDictionary
    @json.each do |k, v|
      if !@ignorefields.include? "hashkey"
        if @caseinfo.include? "hashkey"
          @outhash[k] = false
        else
          @outhash[k] = true
        end
      end

      if !@ignorefields.include? "hashval"
        if @caseinfo.include? "hashval"
          @outhash[v] = false
        else
          @outhash[v] = true
        end
      end
    end
  end
end
