#!/usr/bin/ruby
# coding: utf-8

require 'rubygems'
require 'text/levenshtein'
require_relative "ocrx_word"
require_relative "alignated_word"

class WordAlignator
    attr_reader :alignated_line, :dropped_ocr_words, :dropped_weak_ocr_words, :no_weak_ocr
    attr_accessor :lookahead
    
    def initialize(ocr_line, weak_ocr_line)
        @ocr_line = ocr_line || []
        @weak_ocr_line = weak_ocr_line || []
        @alignated_line = []
        @dropped_ocr_words = []
        @dropped_weak_ocr_words = []
        @no_weak_ocr = []
        @lookahead = 2
    end
    
    def alignate
        @ocr_line.each_with_index do |ocr_word, pos|
            ocrx_word =  @weak_ocr_line[pos]
            
            # Wenn keine Weak_OCR_mehr
            unless ocrx_word then
                @no_weak_ocr <<  @ocr_line[pos..-1]
                break
            end
            

            distance = Text::Levenshtein.distance( ocr_word, ocrx_word.text)

            # Wenns irgendwie passt nehmen
            if distance <= 1 then
                @alignated_line << AlignatedWord.new(
                                      ocrx_word.x1, ocrx_word.y1,
                                      ocrx_word.x2, ocrx_word.y2,
                                      ocr_word,
                                      ocrx_word.text,
                                      distance,
                                      'marked')
            else
                case best_distance(pos, distance)
                    when :initial then
                        @alignated_line << AlignatedWord.new(
                                              ocrx_word.x1, ocrx_word.y1,
                                              ocrx_word.x2, ocrx_word.y2,
                                              ocr_word,
                                              ocrx_word.text,
                                              distance,
                                              'marked_bad')
                    when :fix_merge then
                        @alignated_line << fix_merge_starting_at(pos)
                    when :fix_split then
                        @alignated_line << fix_split_starting_at(pos)
                    when :drop_ocr then
                        @alignated_line << drop_ocr_at(pos)
                    when :drop_weak_ocr then
                        @alignated_line << drop_weak_ocr_at(pos)
                    else
                        puts "Error"
                        p best_distance(pos, distance)
                end
                
            end
           
           
        end
    end
    
    def best_distance(pos, initial_distance)
        
        distances = {
            :initial        => { :distance => initial_distance },
            :fix_merge          => distance_if_merge_at(pos),
            :fix_split          => distance_if_split_at(pos),
            :drop_ocr       => lookahead_drop_ocr(pos, @lookahead),
            :drop_weak_ocr  => lookahead_drop_weak_ocr(pos, @lookahead)
        }
        
        minimal_distances = min_distances(distances)
        
        # Mehr als eine Möglichkeit
        if minimal_distances.length > 1 then
            # Je nach verbleibender Wortanzahl in Zeile ist eine andere Vorgehensweise zu bevorzugen
            word_count_difference =  @ocr_line.length - @weak_ocr_line.length
            # Mehr OCR als WeakOCR
            if word_count_difference > 0 then
                prefer(minimal_distances, :fix_merge, :drop_ocr, :initial)
            # Mehr WeakOCR als OCR
            elsif word_count_difference < 0 then
                prefer(minimal_distances, :fix_split, :drop_weak_ocr, :initial)
            else
                prefer(minimal_distances, :initial, :fix_merge, :fix_split)
            end
        else
            minimal_distances[0]
        end
    end
    
    def prefer(available_symbols, *symbols)
        for symbol in symbols do
            if available_symbols.find {|available_symbol| available_symbol == symbol } then
                return symbol
            end
        end
        available_symbols[0]
    end
    
    def min_distances(distances)
         # Minimumwerte finden
            min_distance = distances.values.collect {|v| v[:distance]}.select{ |d| !d.nil? }.min

            functions_with_best_distances = distances.keys.find_all { |possible_distance|
                distances[possible_distance][:distance] == min_distance
                }
            # Hier guter Punk für Ausgabe
            functions_with_best_distances
    end
    
    def distance_if_merge_at(pos)
        
        ocr_word        = @ocr_line[pos] 
        weak_ocr_word   = @weak_ocr_line[pos]
        
        if weak_ocr_word and weak_ocr_word.text.length >= ocr_word.length then
            weak_ocr_sub_sequence = weak_ocr_word.text.scan(/./u)[0..ocr_word.length() - 1].to_s
            reamaining_word = weak_ocr_word.text[ocr_word.length..-1]
            if reamaining_word && reamaining_word.length > 0 then
                distance = Text::Levenshtein.distance(weak_ocr_sub_sequence,ocr_word)
            end
        end
        {:distance => distance}
    end
    
    def distance_if_split_at(pos)
        split_count         = 1
        ocr_word            = @ocr_line[pos]
        if @weak_ocr_line[pos] then
            best_distance       = Text::Levenshtein.distance( ocr_word, @weak_ocr_line[pos].text )
            word_with_best_distance = @weak_ocr_line[pos]
            fixed_ocrx_word     = join_splitted_word(pos, split_count)
            distance_fixed_ocrx_word = Text::Levenshtein.distance( ocr_word, fixed_ocrx_word.text)

            while (distance_fixed_ocrx_word < best_distance) do
                word_with_best_distance = fixed_ocrx_word
                best_distance = distance_fixed_ocrx_word
                split_count += 1
            
                fixed_ocrx_word = join_splitted_word(pos,split_count)
                distance_fixed_ocrx_word = Text::Levenshtein.distance( ocr_word, fixed_ocrx_word.text)
            end
        end
        {:distance => best_distance, :best_fixed_word => word_with_best_distance}
    end
    
    def lookahead_drop_ocr(pos, count)
        weak_ocr_word = weak_ocr_word_from(@weak_ocr_line[pos])
        distances  = Hash.new()
        
        count.downto(1) do |c|
            ocr_word = @ocr_line[pos + c]
            if ocr_word then
                distance = Text::Levenshtein.distance(ocr_word,weak_ocr_word)
                distances[distance] = c
            end
        end
        min_count_and_distance(distances)
    end
    
    def lookahead_drop_weak_ocr(pos, count)
        ocr_word   = @ocr_line[pos]
        distances  = Hash.new()
        
        count.downto(1) do |c|
            ocrx_word = @weak_ocr_line[pos + c]
            if ocrx_word then
                distance = Text::Levenshtein.distance(ocr_word, ocrx_word.text)
                distances[distance] = c
            end
        end
        min_count_and_distance(distances)
    end
    
    def min_count_and_distance(distances)
        unless distances.empty?
            min_distance = distances.keys.min
            min_count    = distances[min_distance]
        else
            min_distance = nil
            min_count    = nil
        end
        {:distance => min_distance, :count => min_count}
    end
    
    def drop_weak_ocr_at(pos)
        lookahead_drop_weak_ocr = lookahead_drop_weak_ocr(pos, @lookahead)
        lookahead_drop_weak_ocr[:count].times do
            @dropped_weak_ocr_words << @weak_ocr_line.delete_at(pos)
        end
        
        ocr_word = @ocr_line[pos]
        ocrx_word = @weak_ocr_line[pos]
        AlignatedWord.new(
                          ocrx_word.x1, ocrx_word.y1,
                          ocrx_word.x2, ocrx_word.y2,
                          ocr_word,
                          ocrx_word.text,
                          lookahead_drop_weak_ocr[:distance],
                          'marked_weak_ocr_drop')
    end
    
    def drop_ocr_at(pos)
        lookahead_drop_ocr = lookahead_drop_ocr(pos, @lookahead)
        lookahead_drop_ocr[:count].times do
            @dropped_ocr_words << @ocr_line.delete_at(pos)
        end
        ocr_word = @ocr_line[pos]
        ocrx_word = @weak_ocr_line[pos]
        AlignatedWord.new(
                          ocrx_word.x1, ocrx_word.y1,
                          ocrx_word.x2, ocrx_word.y2,
                          ocr_word,
                          ocrx_word.text,
                          lookahead_drop_ocr[:distance],
                          'marked_ocr_drop')
    end
    
    
    #Split reparieren, modifies @weak_ocr_line
    def fix_split_starting_at(pos)
        split_count         = 1
        ocr_word            = @ocr_line[pos]
        best_distance       = Text::Levenshtein.distance( ocr_word, @weak_ocr_line[pos].text)
        word_with_best_distance = @weak_ocr_line[pos]
        fixed_ocrx_word     = join_splitted_word(pos,split_count)
        distance_fixed_ocrx_word = Text::Levenshtein.distance( ocr_word, fixed_ocrx_word.text)
        
        puts "Fix Split: Distance init :#{best_distance} -> #{distance_fixed_ocrx_word} | #{ocr_word}:#{@weak_ocr_line[pos].text}"
        puts "\tFixed: *#{fixed_ocrx_word.text}* Before: *#{word_with_best_distance.text}* Target: *#{ocr_word}*"
        
        while (distance_fixed_ocrx_word < best_distance) do
            puts "\t\tVorheriger Wortabstand -> Jetziger Wortabstand :#{best_distance} -> #{distance_fixed_ocrx_word}"
            puts "\t\t#{fixed_ocrx_word.text}| better than |#{word_with_best_distance.text}| for |#{ocr_word}|"
            
            word_with_best_distance = fixed_ocrx_word
            best_distance = distance_fixed_ocrx_word
            split_count += 1
            
            fixed_ocrx_word = join_splitted_word(pos,split_count)
            distance_fixed_ocrx_word = Text::Levenshtein.distance( ocr_word, fixed_ocrx_word.text)
        end
        
        
        puts "\tPos before #{pos}"

        puts "Deleting #{split_count} words starting at #{pos}"
        removed_words = remove_words( pos, split_count )
        @weak_ocr_line.insert(pos, word_with_best_distance)
        @word_count_difference = @ocr_line.length - @weak_ocr_line.length
        
        # markiert wie gut der Reperaturversuch war
        if best_distance <= 1 || (ocr_word.length >= 4 and best_distance <= 2) or (ocr_word.length >= 10 and best_distance <= 4) then
  
            AlignatedWord.new(word_with_best_distance.x1,word_with_best_distance.y1,
                              word_with_best_distance.x2,word_with_best_distance.y2,
                              @ocr_line[pos],
                              "#{removed_words.collect{|w| w.text}.join("+")} --> #{word_with_best_distance.text}",
                              best_distance,
                              'marked_split'
                              )
        else
            AlignatedWord.new(word_with_best_distance.x1,word_with_best_distance.y1,
                              word_with_best_distance.x2,word_with_best_distance.y2,
                              @ocr_line[pos],
                              "#{removed_words.collect{|w| w.text}.join("+")} --> #{word_with_best_distance.text}",
                              best_distance,
                              'marked_split_fail'
                              )
        end
    end
    
    
    def remove_words( start_pos, num)
        removed_words = []
        while (num > 0) do
            removed_words  << @weak_ocr_line.delete_at(start_pos)
            num -= 1
        end
        puts "Deleted #{removed_words.join(" ")} at #{start_pos}"
        removed_words
    end
    
    
    def fix_merge_starting_at(pos)
        ocr_word        = @ocr_line[pos]
        weak_ocr_word   = @weak_ocr_line[pos]
        weak_ocr_sub_sequence = weak_ocr_word.text.scan(/./u)[0..ocr_word.length() - 1].to_s
        
        distance = Text::Levenshtein.distance(weak_ocr_sub_sequence,ocr_word)
        
        puts "WeakOCR: |#{weak_ocr_word.text}| SUB: |#{weak_ocr_sub_sequence}| ~> OCR:|#{ocr_word}|"
        # Berechnen für Anzeige
        marker_len = weak_ocr_word.x2 - weak_ocr_word.x1
        esitimated_char_length = marker_len.to_f/ weak_ocr_word.text.length
        
        # Hier sollte ein Neues ocrx_wort erstellt und in WeakOCR eingbaut weden
        reamaining_word = weak_ocr_word.text[ocr_word.length..-1]
        est_start_position = weak_ocr_word.x2 - reamaining_word.length() * esitimated_char_length

        estiamted_ocrx_word = OCRXWord.new(
                                    est_start_position, weak_ocr_word.y1, 
                                    weak_ocr_word.x2, weak_ocr_word.y2,
                                    reamaining_word
                                    )
        @weak_ocr_line.insert(pos + 1, estiamted_ocrx_word)
        
        # Position für Aliginertes Wort
        esitimated_end_position = weak_ocr_word.x1 + esitimated_char_length * ocr_word.length
        
        # Ist am Anfang des Wortes genau zu finden
        if distance == 0 || ocr_word.length > 2 && distance <= 1
            
            AlignatedWord.new(weak_ocr_word.x1,weak_ocr_word.y1,
                               esitimated_end_position, weak_ocr_word.y2,
                               ocr_word,
                               "#{@weak_ocr_line[pos].text} --> #{weak_ocr_sub_sequence}",
                               distance,
                               'marked_merge'
                                )
        else
             AlignatedWord.new(weak_ocr_word.x1,weak_ocr_word.y1,
                                esitimated_end_position, weak_ocr_word.y2,
                                ocr_word,
                                "#{@weak_ocr_line[pos].text} --> #{weak_ocr_sub_sequence}",
                                distance,
                               'marked_merge_fail'
                                )
        end
    end
    
    def weak_ocr_word_from(ocr_x_word)
        if ocr_x_word then
            ocr_x_word.text
        else
            ""
        end
    end
    

    
    def join_splitted_word(split_start, count)
        split = @weak_ocr_line[split_start .. split_start + count ]
        #puts "\t\t\tTry to join -> #{split.collect{|w|w.text}.join("_")} -> l: #{split.length}"
         fixed_word = split.collect{ |ocrx_w| ocrx_w.text}.join("")
        # Verhindern wenn merge mit Satzzeichen, dass falsche Höhe verwendet wird
        y2_max = split.collect{|w| w.y2.to_i}.max
        y1_min = split.collect{|w| w.y1.to_i}.min
        OCRXWord.new( split[0].x1, y1_min, split[-1].x2, y2_max, fixed_word)
    end
    
    
    
end
