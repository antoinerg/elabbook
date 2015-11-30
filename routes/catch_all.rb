class Elabbook < Sinatra::Base  
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