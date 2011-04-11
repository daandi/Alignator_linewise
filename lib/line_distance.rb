#!/usr/bin/ruby

require 'rubygems'
require 'text/levenshtein'

class LineDistance
    
    attr_reader :distance, :liklihood, :word_distances
    
    def initialize(ocr_line, weak_ocr_line)
        @ocr_line               = ocr_line || [""]
        @weak_ocr_line          = weak_ocr_line || [""]
        @longest_line           = choose_longest_line()
        @word_distances = []
        calculate_liklihood()
        verbose()
    end
    
    
    def calculate_line_distance
        Text::Levenshtein.distance(@ocr_line.join(" "),@weak_ocr_line.join(" "))
    end
    
    def calculate_liklihood
           distance = calculate_line_distance
           optimal  = @longest_line.join(" ").length
           @liklihood = (optimal - distance).to_f / optimal
    end
    
    def choose_longest_line
        if @ocr_line.length >= @weak_ocr_line.length
            @ocr_line
        else
            @weak_ocr_line
        end
    end
    
    def verbose
        puts "    OCR Text  -> #{ @ocr_line.join(" ") }"
        puts "WeakOCR Text  -> #{ @weak_ocr_line.join(" ") }"
        puts "Liklelihood   -> #{ @liklihood }"
    end
    
end

__END__

x = LineDistance.new(["Loter", "Schönheit", "test"],["*"])
p 