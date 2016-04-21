require 'rest-client'
module Nginx
  def self.get(path)
  	resp=RestClient.get File.join($settings_file_server,path)
  	return resp.to_s
  end

  def self.exists?(path)
  	begin
  		resp=RestClient.head(File.join($settings_file_server,path)) {|resp,req,res| response.return(resp,req,res)}
  	rescue
  		return false
  	end
  	resp.code == 200
  end

  def self.directory?(path)
  	return true if path[-1,1] == "/"
  	/^(?<parent_folder>\/.*\/)(?<name>[^\/]*)$/ =~ path
	
	entries = self.entries(parent_folder)
    entry = entries.find {|e| e["name"] == name }
    return entry["type"] == "directory"
  end

  def self.entries(path)
  	begin
  		resp = RestClient.get File.join($settings_file_server,path)
  		return JSON.parse(resp.to_s)
  	rescue
  		return nil
  	end
  	
  end

end