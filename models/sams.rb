config_file File.join( [settings.root, 'config', 'config.yml'] )

class Sams < Sample
  def self.all
    logs = [];
    find(File.join(settings.dir,'/data/sample_preparation/sams')) do |f|
      if f.match(/.*log.xml$/)
        logs << Sams.new(f)
      end
    end
    return logs
  end
  
  def to_json
    json = JSONBuilder::Compiler.generate do
    	id self.id
      	title self.title
      	date self.datetime

      	procedure @xml.xpath('/log/procedure/step').to_a do |step|
      		key "step_#{step.attribute('id')}" do
      			type step.at_xpath('type').content
      			concentration step.at_xpath('concentration').content.to_f/1000 || 0
      			time ISO8601::Duration.new(step.at_xpath('time').content).to_seconds / 60
      		end
        end
    end
    return json
  end
end
