require_relative '../app.rb'
config_file File.join( [settings.root, 'config', 'config.yml'] )
require 'nokogiri'

require_relative '../lib/find.rb'

find(File.join(settings.dir,'data/lt-afm/scanita')) do |f|
  if f.match(/.*xml/)
    doc = Nokogiri::XML(File.read(f))
    fits=doc.xpath("/SPM/Package/UserChannel[Name = 'Dissipation peaks']/UserData/Fitting//peak")

    if !fits.empty?
      puts fits
    end
  end
end