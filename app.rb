require 'sinatra'
require 'sinatra/base'
require "sinatra/config_file"

require 'json'
require 'nokogiri'
require 'date'

class Elabbook < Sinatra::Base
register Sinatra::ConfigFile
config_file 'config.yml'

get '/data/lt-afm/scanita/*/:name.sdf' do
  @path = request.fullpath
  @filename = params[:name] + ".sdf"
  @folder = File.join(settings.dir,@path.gsub(@filename,''))

  # Loading XML
  @xml_path = File.join(settings.dir,@path + ".xml")
  if File.exist?(@xml_path)
    Dir.chdir(@folder) do
      @xml = Nokogiri::XML(File.read(@xml_path),&:xinclude)
      @datetime = DateTime.iso8601(@xml.xpath('/SPM/Package/Date').first.content)
      @type = @xml.xpath('/SPM/Package/Type').first.content
    end
  end

  # Loading images
  @image_dir=File.join(@folder,'..','img')
  @images = Dir.entries(@image_dir)[2..-1].sort.select {|f| f.match("#{@filename}.*svg$")}.collect {|f| File.join(@image_dir,f).gsub(settings.dir,'')}
  
  # Provide link to next data file in same folder
  files = Dir.entries(@folder)[2..-1].sort.keep_if {|f| f.match(/.*sdf$/)}
  id=files.find_index(@filename)
  @next_url = files.fetch(id+1,files[0])
  @previous_url = files.fetch(id-1)
  
  # Render the stuff based on type
  erb :scanita, :layout => :html5
end

get '/data/lt-afm/scanita/*/:day/raw' do
  @path = request.fullpath
  @folder = File.join(settings.dir,@path)
  Dir.chdir(@folder) do
    @xmls = Dir.entries(@folder)[2..-1].sort.select {|f| f.match(/.*xml$/)}.collect do |f|
	Nokogiri::XML(File.read(f))
    end
  end
  @datetime = DateTime.iso8601(params[:day])
  erb :"scanita/daily_report", :layout => :html5
end

get '/api/*' do
  p = path
  if File.exists?(p)
    return [200,list_file(p).to_json] if File.directory?(p)
    [200,File.read(p)]
  else
    [404,"Not found"]
  end 
end

delete '/api/*' do
  p = path
  File.delete(p)
  [200,"Deleted"]
end

post '/api/*' do
  p = path
  if File.exists?(p)
    return[500,"File already exists"]
  else
    File.open(p,'w') do |f|
      f.write(request.body.read)
      [201,"Created"]
    end
  end
end

put '/api/*' do
  p = path
  if File.exists?(p)
    File.open(p,'w') do |f|
      f.write(request.body.read)
      return[200,"Updated"]
    end
  else
    return[404,"Not found"]
  end
end

get '*' do
  path = path(params[:splat] || '')
  if File.directory?(path)
    @folders = list_file(path)  
    erb :index, :layout => :html5
  else
    redirect settings.file_server + path.gsub(settings.dir,'')
  end
end

def list_file(path)
  return Dir.entries(path).sort[2..-1].collect {|f| File.join(path,f).gsub(settings.dir,'')}
end

def path(url=params[:splat])
  #root = File.dirname(__FILE__)
  root = settings.dir
  path = File.join(root,url)
end
end
