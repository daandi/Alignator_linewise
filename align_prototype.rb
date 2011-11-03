require_relative 'html_output'

#bsb data bsb10001486_00020 bsb10230377_00020 bsb10354982_00020 bsb10373337_00010 bsb10223976_00020 bsb10293430_00020 bsb10371498_00020 bsb10445992_00020 bsb10227255_00020 bsb10302791_00021 bsb10372319_00020 bsb10446069_00020

for id in ["Ein_erschoecklich_gschicht_Vom_Tewfel", "Ueber_den_Gebrauch_des_englischen_Wortes_Sir","Sant_kmernusl"] do
    #begin
        puts id
        page = HtmlOutput.new(id,0.2)
    #rescue
       # puts "Fehler"
    #end
end




