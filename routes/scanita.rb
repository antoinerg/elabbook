class Elabbook < Sinatra::Base
=begin HTTP-based
  get '/data/lt-afm/scanita/*/:name.sdf' do
    @path = request.fullpath + ".xml"
    @sdf = SDF.new(@path)

    @next_url = "files.fetch(id+1,files[0])"
    @previous_url = "files.fetch(id-1)"

    # Render the stuff based on type
    erb :scanita, :layout => :html5

  end

  get '/data/lt-afm/scanita/*/:day/raw' do
    @path = request.fullpath
    entries = ::Nginx.entries(@path)
    @sdfs = entries(@folder).select {|f| f["name"].match(/.*xml$/)}.collect do |f|
        SDF.new(@path)
    end
    #@datetime = DateTime.iso8601(params[:day])
    erb :"scanita/daily_content", :layout => :html5
  end
=end

  get '/data/lt-afm/*/:name.sdf' do
    headers "Cache-Control" => "max-age=10"
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

  get '/data/lt-afm/*/:day/raw' do
    @path = request.fullpath
    @folder = path(@path)
    Dir.chdir(@folder) do
      @sdfs = Dir.entries(@folder).sort.select {|f| f.match(/.*xml$/)}.collect do |f|
        SDF.new(f)
      end
    end
    @datetime = DateTime.iso8601(params[:day])
    @sdfs.sort! {|a,b| a.datetime <=> b.datetime}
    erb :"scanita/daily_content", :layout => :html5
  end
end