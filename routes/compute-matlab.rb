class Elabbook < Sinatra::Base
  get '/compute-matlab/:hash' do
    headers "Cache-Control" => "max-age=10"
    hash=params["hash"]
    root = "https://elabbook.antoineroygobeil.com/cdn/compute-matlab/#{hash}/"

    resp = RestClient.get(root)
    files = JSON.parse(resp).collect {|f| root + f["name"]}

    resp = RestClient.get(root + "compute.json")
    compute = JSON.parse(resp)

    @vars = {
      "compute" => compute,
      "hash" => hash,
      "files" => files
    }

    # Render the stuff based on type
    erb :"compute-matlab/index", :layout => :html5
  end
end