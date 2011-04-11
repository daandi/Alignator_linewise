require_relative "ocrx_word"

class WeakOCR
    attr_reader :lines, :weak_ocr
    
    def initialize(filename)
        weak_ocr_contents = File.open(filename,"r") { |f| f.read }
        @lines = weak_ocr_lines(weak_ocr_contents).select {|line| line.length > 0}
    end
    
    def weak_ocr_lines(weak_ocr_contents)
        weak_ocr_array = []
        for line in weak_ocr_contents.split(/<span class="ocr_line"/) do
            line_array = []
            for ocrx_word in line.scan(/<span class="ocrx_word"[^>]+>[^<]+<\/span>/) do
                ocrx_word =~ /title="bbox (\d+) (\d+) (\d+) (\d+)">([^<]+)</
                current_word = OCRXWord.new($1,$2,$3,$4,$5)
                line_array << current_word
            end
            weak_ocr_array << line_array
        end            
        weak_ocr_array
    end
    
    def get_position(element)
        element =~ /title="bbox (\d+) (\d+) (\d+) (\d+)">/
        [$1,$2,$3,$4]
    end
    
end
