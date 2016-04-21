class Elabbook < Sinatra::Base
=begin HTTP-based
  get '*' do
    path = params[:splat] || ''
    path = path[0]
    if ::Nginx.directory?(path)
      path = path + "/" if path[-1,1] != "/"
      @folders = ::Nginx.entries(path)
      @path = params[:splat][0]
      @folders.collect! do |e|
        trailer = e["type"] == "directory" ? "/" : ""
        e["name"] + trailer
      end
      erb :index, :layout => :html5
    else
      redirect File.join($settings_file_server,path)
    end
  end
=end

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
      redirect $settings_file_server + path.gsub(/^#{$settings_dir}/,'')
    end
  end

end