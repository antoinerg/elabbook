class Elabbook < Sinatra::Base
  get /^\/data\/lt-afm\/nanonis\/.*(dat|sxm)(\/partial)?$/ do
    @path = request.fullpath.gsub('/partial','') + ".xml"
    @nanonis = Nanonis.new(path(@path))

    # Provide link to next data file in same folder
    files = Dir.entries(@nanonis.folder).sort.keep_if {|f| f.match(/.*(dat|sxm)$/)}
    id=files.find_index(@nanonis.filename)
    @next_url = files.fetch(id+1,files[0])
    @previous_url = files.fetch(id-1)

    partial = (params['captures'][1]=="/partial")

    if partial
      erb :nanonis, :layout => nil
    else
      erb '<!--# include virtual="<%=request.fullpath%>/partial" wait="yes" -->', :layout => :html5
    end
  end

  get '/data/lt-afm/nanonis/*/raw' do
    @path = request.fullpath
    @folder = path(@path)
    Dir.chdir(@folder) do
      @spms = Dir.entries(@folder).sort.select {|f| f.match(/.*xml$/)}.collect do |f|
        SPM.new(f)
      end
    end
    #@datetime = DateTime.iso8601(params[:day])
    erb :"nanonis/experiment_content", :layout => :html5
  end
end