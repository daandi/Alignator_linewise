class OCR
    
    attr_reader :lines
    
    def initialize(filename)
        file = File.open(filename,"r")
        @lines = read_ocr_lines(file)
    end
    
    def read_ocr_lines(file)
        ocr_array = []
        for line in file do
            temp_array = []
            for word in line.split(" ") do
                temp_array << word
            end
            ocr_array << temp_array
        end
        ocr_array
    end
    
    
end