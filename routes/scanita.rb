class Elabbook < Sinatra::Base
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
end