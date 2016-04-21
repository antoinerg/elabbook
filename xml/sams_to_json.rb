require 'json_builder'
require 'nokogiri'
require 'iso8601'

doc = Nokogiri::XML(File.read(ARGV[0]))
#puts doc.xpath('/log/procedure/step').type
json = JSONBuilder::Compiler.generate do
	id doc.at_xpath('/log/sample').content
  	title doc.at_xpath('/log/title').content
  	date DateTime.iso8601(doc.at_xpath('/log/date').content)

  	procedure doc.xpath('/log/procedure/step').to_a do |step|
  		key "step_#{step.attribute('id')}" do
  			type step.at_xpath('type').content
  			concentration step.at_xpath('concentration').content.to_f/1000 || 0
  			time ISO8601::Duration.new(step.at_xpath('time').content).to_seconds / 60
  		end
    end
end

puts json