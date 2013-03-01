namespace :index do
namespace :sams do
  
  desc "Create or update SAMS mapping"
  task :mapping do
    command = <<-EOF
    #!/bin/sh

    curl -XPUT 'http://es.lxc:9200/elabbook/sams/_mapping' -d '{
          "sams" : {
            "properties" : {
              "procedure.step_1" : {
                "properties" : {
                  "type" : { "type" : "string", "index": "not_analyzed" }
                }
              },
              "procedure.step_1.duration" : {
                "properties" : {
                  "type" : { "type" : "double", "store": "yes" }
                }
              },
              "procedure.step_2" : {
                "properties" : {
                  "type" : { "type" : "string", "index": "not_analyzed" }
                }
              },
              "procedure.step_3" : {
                "properties" : {
                  "type" : { "type" : "string", "index": "not_analyzed" }
                }
              },
              "title" : { "type" : "string" }
            }
          }
      }
    ' 
    EOF
    
    system(command)
  end
  
  desc "Update SAMS index"
  task :update do
    require './lib/elasticsearch.rb'
    require './xml/sams_log_to_es.rb'
    require './lib/find.rb'
    es = ElasticSearch.new
    find('/Volumes/share/data/sams') do |f|
      if File.basename(f) == 'log.xml'
        begin
        #puts "Indexing #{f}"
        es.publish(SAMS_log.batch(f))
        rescue Exception => e
        puts "Failed #{f}"
        puts e.message
        puts e.backtrace
        end
      end
    end
    es.stop
  end
  
  desc "Test SAMS conversion"
  task :test, [:file] do |t,args|
    require './xml/sams_log_to_es.rb'
    puts SAMS_log.convert(args[:file])
    puts "#{args[:file]}"
  end
end
end
