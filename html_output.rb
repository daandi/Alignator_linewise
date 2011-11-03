#coding: utf-8

require_relative 'lib/alignator'
require_relative 'lib/ocrx_word'
require 'erb'

class HtmlOutput
    
    
    def initialize(id_and_page, min_distance_liklihood = 0.1)
        
        puts id_and_page
        
        @image_url = "../Images/" + id_and_page + ".jpg"
        ocr = "data/OCR/" + id_and_page + ".txt"
        weak_ocr = "data/WeakOCR/" + id_and_page + ".html"
        
        @html = File.open("data/html_out/" + id_and_page + "_debug.html", "w+")

        
        alignated = Alignator.new(ocr, weak_ocr, min_distance_liklihood)
        @alignated_words    = alignated.alignated_words
        @surplus_lines      = alignated.surplus_lines
        @dropped_words  = alignated.dropped_words
        @alignated_words    = [alignated.alignated_words.flatten]
        @sorted_alignated_words = @alignated_words.flatten.sort_by {|a| a.distance}.reverse
        
        write_file
    end
    
    def write_file
        @html << ERB.new( File.open('alignated_image.erb' ){ |f| f.read } ).result( binding )
    end
    
end

__END__

#HtmlOutput.new "bsb10001486_00020", 0.2 # Sehr schlechtes Ergebnis, Falsche Zuordnung, Fehler, Starke Zeilendifferenz
#HtmlOutput.new("bsb10223976_00020",0.1) # Ok, starke Verbesserung zu vorheriger Heuristik, sehr schiefer Scan (Bibel), Problem gegen Textende, Zeilendiffernez
#HtmlOutput.new("bsb10227255_00020",0.2)# Gut, EIne Zeile gelöscht. Merges und SPlits repariert.
#HtmlOutput.new("bsb10230377_00020",0.2) #OK, ein paar Worte fehlen im OCR ?, manchmal Fehlzuordnubng SPLITs, Probleme
#HtmlOutput.new("bsb10293430_00020") # nur halbe Spalte erkannt bei Weak OCR
#HtmlOutput.new "bsb10302791_00021", 0.2 # Schlecht, Klammern, Hierachie
#HtmlOutput.new"bsb10354982_00020", 0.2 # Zweiter Abschnitt gut, erster um eine Zeile verschoben, mehr Lookahead testen hier
#HtmlOutput.new("bsb10371498_00020") # ok, Antiqua
#HtmlOutput.new "bsb10372319_00020",0.2 # ok, Probleme mit Zeilenalignierung
#HtmlOutput.new  "bsb10373337_00010", 0.2 # gut
#HtmlOutput.new "bsb10445992_00020", 0.2 # gut, split bei weak OCR reparieren 
#HtmlOutput.new "bsb10446069_00020", 0.2 # Mies

