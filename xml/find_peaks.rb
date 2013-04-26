require 'nokogiri'

require_relative '../lib/find.rb'

find('/mnt/elabbook/data/lt-afm/scanita') do |f|
  if f.match(/.*xml/)
    doc = Nokogiri::XML(File.read(f))
    fits=doc.xpath("/SPM/Package/UserChannel[Name = 'Dissipation peaks']/UserData/Fitting//peak")

    if !fits.empty?
      puts fits
    end
  end
end