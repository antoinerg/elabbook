# SINATRA framework
require 'sinatra'
require 'sinatra/base'
require "sinatra/config_file"
require 'sinatra/partial'

# Helpful gems
require 'json'
require 'nokogiri'
require 'date'
require 'json_builder'

# Ruby objects to help deal with various data files and their relatives representations
require './models/spm.rb'
require './models/sdf.rb'
require './models/sdf_image.rb'
require './models/nanonis.rb'
require './models/sample.rb'
require './models/sams.rb'

require './lib/find.rb'

class Elabbook < Sinatra::Base
  register Sinatra::ConfigFile
  config_file 'config/config.yml'

  $settings = settings

  register Sinatra::Partial
  set :partial_template_engine, :erb

  set :absolute_redirects, false

  get /^\/data\/lt-afm\/nanonis\/.*(dat|sxm)$/ do
    @path = request.fullpath + ".xml"
    @nanonis = Nanonis.new(path(@path))

    # Provide link to next data file in same folder
    files = Dir.entries(@nanonis.folder).sort.keep_if {|f| f.match(/.*(dat|sxm)$/)}
    id=files.find_index(@nanonis.filename)
    @next_url = files.fetch(id+1,files[0])
    @previous_url = files.fetch(id-1)

    erb :nanonis, :layout => :html5
  end

  get '/data/sample_preparation/*/log.xml' do
    @path = request.fullpath
    @sample = Sample.new(path(@path))
    erb :sample, :layout => :html5
  end

  get '/data/lt-afm/scanita/*/:name.sdf' do
    @path = request.fullpath + ".xml"
    @sdf = SDF.new(path(@path))

    # Provide link to next data file in same folder
    files = Dir.entries(@sdf.folder).sort.keep_if {|f| f.match(/.*sdf$/)}
    id=files.find_index(@sdf.filename)
    @next_url = files.fetch(id+1,files[0])
    @previous_url = files.fetch(id-1)

    # Render the stuff based on type
    erb :scanita, :layout => :html5
  end

  get '/data/lt-afm/scanita/*/:day/raw' do
    @path = request.fullpath
    @folder = path(@path)
    Dir.chdir(@folder) do
      @sdfs = Dir.entries(@folder).sort.select {|f| f.match(/.*xml$/)}.collect do |f|
        SDF.new(f)
      end
    end
    @datetime = DateTime.iso8601(params[:day])
    erb :"scanita/daily_content", :layout => :html5
  end

  get '/api/*' do
    p = path(params[:splat])
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
    p = path(params[:splat])
    if File.exists?(p)
      File.open(p,'w') do |f|
        f.write(request.body.read)
        return[200,"Updated"]
      end
    else
      return[404,"Not found"]
    end
  end

  get '*.erb.html' do
    path = path(request.fullpath)
    if File.exists?(path)
      tmpl = File.read(path)
      erb tmpl, :layout => :html5
    else
      path
    end
  end

  get '*' do
    path = path(params[:splat] || '')
    if File.directory?(path)
      @folders = list_file(path)
      if @folders.detect {|f| f.match(/.*index.erb.html$/)}
        redirect File.join('/',params[:splat],'index.erb.html')
      end
      @path = params[:splat][0]
      erb :index, :layout => :html5
    else
      redirect settings.file_server + path.gsub(/^#{settings.dir}/,'')
    end
  end

  helpers do
    def load_xml(p)
      xml_path = path(p)
      if File.exist?(xml_path)
        xml = Nokogiri::XML(File.read(xml_path),&:noblanks)
      end
      return xml
    end

    def list_file(path)
      return Dir.entries(path).sort[2..-1].collect {|f| File.join(path,f).gsub(/^#{settings.dir.chomp('/')}/,'')}
    end

    def path(url=request.fullpath)
      root = settings.dir
      path = File.join(root,url)
    end

    def url(filepath)
      "/" + filepath.gsub(/^#{settings.dir}/,'')
    end

    def url_cdn(p)
      settings.file_server + p.gsub(/^#{settings.dir}/,'')
    end

    def svg_tag(image,html_class='')
      html = []
      html << "<figure class='#{html_class}'>"
      html << "<figcaption>#{image.title}</figcaption>"
      url = url_cdn(image.svg_path)
      html << "<object type='image/svg+xml' data='#{url}'></object><a class='noprint' href='#{url}'>Download</a>"

      html << "</figure>"
      html.join("\n")
    end

    def png_tag(image,html_class='')
      html = []
      html << "<figure class='#{html_class}'>"
      html << "<figcaption>#{image.title}</figcaption>"
      url = url_cdn(image.png_path)
      html << "<a href='#{url}'><img style='width:100%' src='#{url}'/></a>"
      html << "</figure>"
      html.join("\n")
    end
  end
end
