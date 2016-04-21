class Elabbook < Sinatra::Base 
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
end