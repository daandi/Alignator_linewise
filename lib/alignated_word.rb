#!/usr/bin/ruby

require_relative "ocrx_word"

class AlignatedWord < OCRXWord
    
    attr_reader :old_text, :distance
    
    def initialize( x1, y1, x2, y2, word, old_word, distance, css_marker_class)
        super(x1,y1,x2,y2,word)
        @old_text = old_word
        @distance = distance
        @css_marker_class = css_marker_class
    end
    
    def to_html
        "\n<span class='alignated_word' style='#{ to_css_style() }' >"+
        "<span class='#{@css_marker_class}'></span>\n" +
        "<span class='info'>" +
        "<span class='word'>" + CGI::escapeHTML(@text) +"</span>"+
        "<span class='old_word'>"+ CGI::escapeHTML(@old_text) + "</span>"+
        "<span class='distance'>" + @distance.to_s + "</span></span></span>\n"
    end
    
    def to_s
        "#{@text}->#{@old_text} #{@distance}"
    end
    
    
end
