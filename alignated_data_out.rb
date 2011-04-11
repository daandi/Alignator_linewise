#coding: utf-8
require_relative 'alignator'

class DataOutput
    
    
    def initialize(id_and_page, min_distance_liklihood = 0.1)
        
        puts id_and_page
        
        weak_ocr = "data/WeakOCR/" + id_and_page + ".html"
        ocr = "data/OCR/" + id_and_page + ".txt"
        
        @data = File.open("data/" + id_and_page + "_alignate_words.marshal", "w+")

        
        alignated = Alignator.new(ocr, weak_ocr, min_distance_liklihood)
        @alignated_words    = alignated.alignated_words
        @surplus_lines      = alignated.surplus_lines
        @dropped_words  = alignated.dropped_words
        
        Marshal.dump(@alignated_words, @data)
        
    end
    
end
#__END__
DataOutput.new "bsb10373337_00010", 0.2
#HtmlOutput.new  "bsb10373337_00010", 0.2