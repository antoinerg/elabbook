class Elabbook < Sinatra::Base
  get /^\/data\/lt-afm\/nanonis\/.*(dat|sxm)(\/partial)?$/ do
    @path = request.fullpath.gsub('/partial','') + ".xml"
    @nanonis = Nanonis.new(path(@path))

=begin
    # Find previous res curve!
    if @nanonis.type == "Frequency Sweep"
      @res_curve = @nanonis
    else
      res_curve_path = files[1,id].reverse.find {|f| f.match(/res_curve.*dat$/)}
      @res_curve = Nanonis.new(File.join(@nanonis.folder,res_curve_path)+".xml")
    end
=end

    partial = (params['captures'][1]=="/partial")

    if partial
      erb '<!--# include virtual="<%=request.fullpath%>/partial" wait="yes" -->', :layout => :nil
    else
      erb :nanonis, :layout => :html5
    end
  end

  get /^\/data\/lt-afm\/nanonis\/.*(dat|sxm)\/peak$/ do
    @path = request.path.gsub('/peak','') + ".xml"
    @nanonis = Nanonis.new(path(@path))
    erb :"nanonis/peak", :layout => :html5
  end

  get '/data/lt-afm/nanonis/*/raw.json' do
    headers "Cache-Control" => "max-age=3600"
    @spms = get_entries_by_date(request.fullpath.gsub(/\.json$/,""))
    #@datetime = DateTime.iso8601(params[:day])
    #erb :"nanonis/experiment_content", :layout => :html5
    out = @spms.collect {|s| {:filename=> s.filename, :format => s.format, :type => s.type, :date => s.datetime}}.to_json
    content_type :json
    return out
  end

  get '/data/lt-afm/nanonis/*/raw' do
    @spms = get_entries_by_date
    #@datetime = DateTime.iso8601(params[:day])
    erb :"nanonis/experiment_content", :layout => :html5
  end

  def get_entries_by_date(path=nil)
    @path = path || request.fullpath
    @folder = path(@path)
    Dir.chdir(@folder) do
      @spms = Dir.entries(@folder).sort.select {|f| f.match(/.*xml$/)}.collect do |f|
        SPM.new(f)
      end
    end
    @spms.sort! {|a,b| a.datetime <=> b.datetime}
  end
end