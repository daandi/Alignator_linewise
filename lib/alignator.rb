# coding: utf-8
require_relative "ocr"
require_relative "weak_ocr"
require_relative "line_distance"
require_relative "word_alignator"

class Alignator
    attr_reader :alignated_lines, :alignated_words, :surplus_lines, :dropped_words
    
    
    def initialize(ocr_file, weak_ocr_file, min_liklihood = 0.1)
        @ocr = OCR.new(ocr_file)
        @weak_ocr =  WeakOCR.new(weak_ocr_file)
        @ocr_lines = @ocr.lines
        @weak_ocr_lines =  @weak_ocr.lines
        
        @min_liklihood = min_liklihood
        @surplus_lines      = {:ocr => [], :weak_ocr => []}
        @alignated_lines    = {:ocr => [], :weak_ocr => []}
        @dropped_words      = {:ocr => [], :weak_ocr => []}
        @alignated_words    = []
        alignate_lines()
        alignate_words()
    end
    
    def alignate_lines
        @ocr_lines.each_with_index do |ocr_line, pos|
            puts "Line: #{pos} OCRLines:#{@ocr_lines.length} WeakOCRLines:#{@weak_ocr_lines.length}"
            distance = LineDistance.new(ocr_line, weak_ocr_line_to_text_line( @weak_ocr_lines[pos] ) )
            # Unwahrscheinliche Alignierung
            if distance.liklihood <  @min_liklihood then
                puts "#{@ocr_lines.length} - #{@weak_ocr_lines.length}"
                line_count_difference = @ocr_lines.length - @weak_ocr_lines.length
                puts "Unwahrscheinliche ALignierung. Versuche zu reparieren."
                # Suche mit Lookahead nach bester Alignierung
                best_ocr_alignation          = look_ahead_ocr(pos,3)
                best_weak_ocr_alignation     = look_ahead_weak_ocr(pos,3)
                # Wenn Verbesserung
                if  best_ocr_alignation[:liklihood]      > @min_liklihood ||
                    best_weak_ocr_alignation[:liklihood] > @min_liklihood then
                    
                    # Wenn wahrscheinlich, dann OCR-Zeilen entfernen
                    if ( best_ocr_alignation[:liklihood] > best_weak_ocr_alignation[:liklihood] ) then
                        remove_surplus_lines_from_ocr(best_ocr_alignation[:count], pos)
                    elsif (best_ocr_alignation[:liklihood] < best_weak_ocr_alignation[:liklihood])
                        remove_surplus_lines_from_weak_ocr(best_weak_ocr_alignation[:count], pos)
                    else
                        # Bei Gleichstand das nehmen wo am wenigsten weggeschmissen wird
                        if (best_ocr_alignation[:count] <= best_weak_ocr_alignation[:count]) then
                            remove_surplus_lines_from_ocr(best_ocr_alignation[:count], pos)
                        else
                            remove_surplus_lines_from_weak_ocr(best_weak_ocr_alignation[:count], pos)
                        end
                    end
                    
                end
                
                  #puts "*********************************"
                  #p @ocr_lines[pos]
                  #p weak_ocr_line_to_text_line(@weak_ocr_lines[pos])  
            end
            
            @alignated_lines[:ocr] << @ocr_lines[pos]
            @alignated_lines[:weak_ocr] << @weak_ocr_lines[pos]
        end
    end
    

    def look_ahead_ocr(pos, count)
        weak_ocr_line   = weak_ocr_line_to_text_line( @weak_ocr_lines[pos])
        liklihoods = Hash.new
        count.downto(1) do |c|
            ocr_line        = @ocr_lines[pos + c] 
            liklihood = LineDistance.new(ocr_line, weak_ocr_line).liklihood
            unless liklihood.nan? then
                liklihoods[liklihood] = c
            end
        end
        max_liklihood =  liklihoods.keys.max || 0
        { :count => liklihoods[max_liklihood] , :liklihood =>  max_liklihood }
    end
    
    def look_ahead_weak_ocr(pos, count)
        ocr_line   = @ocr_lines[pos]
        liklihoods = Hash.new
        count.downto(1) do |c|
            weak_ocr_line = weak_ocr_line_to_text_line( @weak_ocr_lines[pos + c]  )
            liklihood = LineDistance.new(ocr_line, weak_ocr_line_to_text_line( @weak_ocr_lines[pos + c]  ) ).liklihood
            unless liklihood.nan? then
                liklihoods[liklihood] = c
            end
        end
        max_liklihood =  liklihoods.keys.max || 0
        { :count => liklihoods[max_liklihood] , :liklihood =>  max_liklihood }
    end
    
    def remove_surplus_lines_from_ocr(count, pos)
        count.times do
            @surplus_lines[:ocr] << @ocr_lines.delete_at(pos)
        end
    end
    
    def remove_surplus_lines_from_weak_ocr(count, pos)
        count.times do
            @surplus_lines[:weak_ocr] << @weak_ocr_lines.delete_at(pos)
        end
    end
    
    
    def weak_ocr_line_to_text_line(weak_ocr_line)
        if weak_ocr_line != nil then
            weak_ocr_line.collect{ |word| word.text}
        else
            [""]
        end
    end
    
    def alignate_words
        @alignated_lines[:ocr].each_with_index do |ocr_line,pos|
            weak_ocr_line = @alignated_lines[:weak_ocr][pos]
            wa = WordAlignator.new(ocr_line, weak_ocr_line)
            wa.alignate()
            @alignated_words << wa.alignated_line
            # Hier sollten die gelöschten Wörter durchgereicht werden
            @dropped_words[:weak_ocr] << wa.dropped_weak_ocr_words
            @dropped_words[:ocr] << wa.dropped_ocr_words
        end
    end
    
end