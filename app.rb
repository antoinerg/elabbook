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
require './models/spm_image.rb'
require './models/nanonis.rb'
require './models/sample.rb'
require './models/sams.rb'

require './lib/find.rb'
require './lib/helper_module.rb'
require './lib/filesystem_over_nginx.rb'

class Elabbook < Sinatra::Base
  #set :static_cache_control, [:public, :stale_while_revalidate => 10]
  helpers HelperModule

  before do
    headers "Cache-Control" => "max-age=10;stale-while-revalidate=360000;"
    headers "xkey" => "elabbook"
  end

  #register Sinatra::ConfigFile
  #config_file 'config/config.yml'

  #$settings = settings
  $settings_dir = ENV["DIR"]
  $settings_file_server = ENV["FILE_SERVER"]

  register Sinatra::Partial

  set :partial_template_engine, :erb
  set :absolute_redirects, false

  get '/data/sample_preparation/*/log.xml' do
    headers "Cache-Control" => "max-age=600;stale-while-revalidate=360000"
    @path = request.fullpath
    @sample = Sample.new(path(@path))
    erb :sample, :layout => :html5
  end

  get '*.erb.html' do
    #headers "Cache-Control" => "no-cache"
    path = path(request.path_info)
    if File.exists?(path)
      tmpl = File.read(path)
      erb tmpl, :layout => :html5
    else
      path
    end
  end
end

require_relative 'routes/nanonis'
require_relative 'routes/scanita'
#require_relative 'routes/file_api'
require_relative 'routes/compute-matlab'
require_relative 'routes/catch_all'
