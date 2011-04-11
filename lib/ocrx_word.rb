class OCRXWord
    
    require 'cgi'
    
    attr_reader :text,  :x1, :y1, :x2, :y2
    
    def initialize(x1,y1,x2,y2,word)        
        @x1 = x1.to_i
        @y1 = y1.to_i
        
        @x2 = x2.to_i
        @y2 = y2.to_i

        @text = word
    end
    
    def to_css_style
        
        top     = @y1
        left    = @x1
        height  = @y2 - @y1
        width   = @x2 - @x1
        
        "position:absolute; top:#{top}px; left:#{left}px; height:#{height}px; width:#{width}px;"
    end
    
    def to_html
        "<span style='#{ to_css_style() }' class='alignated_word'><span class='word'>" + CGI::escapeHTML(@text) +"</span></span>\n"
    end
    
    def to_html(css_class)
        "<span style='#{ to_css_style() }' class='" + css_class + "'><span class='word'>" + CGI::escapeHTML(@text) +"</span></span>\n"
    end
    
    def to_s
        "#{@text} (#{@x1},#{@y1}) / (#{@x2},#{@y2})"
    end
    

    
    
end

__END__
test = OCRXWord.new("1","2","3","4","test")
p test.to_css_style
p test