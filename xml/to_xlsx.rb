require 'axlsx'
require 'nokogiri'

doc = Nokogiri::XML(File.read('/tmp/summary.xml'))

Axlsx::Package.new do |p|
  p.workbook.add_worksheet(:name => "Pie Chart") do |sheet|
    sheet.add_row ["Simple Pie Chart"]
    %w(first second third).each { |label| sheet.add_row [label, rand(24)+1] }
    sheet.add_chart(Axlsx::Pie3DChart, :start_at => [0,5], :end_at => [10, 20], :title => "example 3: Pie Chart") do |chart|
      chart.add_series :data => sheet["B2:B4"], :labels => sheet["A2:A4"],  :colors => ['FF0000', '00FF00', '0000FF']
    end
  end
  p.serialize('/tmp/summary.xlsx')
end
