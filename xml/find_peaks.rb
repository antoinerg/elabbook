require_relative '../app.rb'
config_file File.join( [settings.root, 'config', 'config.yml'] )
require_relative '../lib/find.rb'

log = Logger.new(STDOUT)
log.level = Logger::ERROR

final = Nokogiri::XML('<summary/>')
summary = final.at_xpath('/summary')

find(File.join(settings.dir,'data/lt-afm/scanita')) do |f|
  if f.match(/.*xml/)
    log.info("Analyzing #{f}")
    doc = Nokogiri::XML(File.read(f))

    fit=doc.xpath("/SPM/Package/UserChannel[Name = 'Dissipation peaks' and Direction = 'Forward']/UserData/Fitting")
    peaks = fit.xpath('//peak')
    if !fit.empty?
	    begin
	      id=doc.at_xpath("/SPM/UserData/metadata/NP/@id").value
	      puts id
	    rescue
	      log.error("#{f} not identified")
	      next
	    end
	node=Nokogiri::XML::Node.new "NP", final
	node["id"] = id
	summary.add_child(node)
	node.add_child(fit)
    end 
  end
end
fd = File.open('summary.xml','w')
final.write_xml_to(fd)
fd.close
