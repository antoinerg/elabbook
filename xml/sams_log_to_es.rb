class SAMS_log

require 'nokogiri'
require 'active_support/core_ext'
require 'json'
require 'iso8601'
require 'nori'

def self.to_hash(path)
  myfuncs = Class.new do
    def concentration(node)
      # do processing here
      return node.text.match(/(\d+).*/) {|m| m[1].to_f/1000} || 'null'
    end
    
    def id(node)
      return node.text.to_i
    end
  end  
  
  Nokogiri::XSLT.register "http://nokogiri.org/antoine", myfuncs
  doc = Nokogiri::XML(File.read(path))
  sams_log = Nokogiri::XSLT(File.read(File.join(File.dirname(__FILE__),'sams_log.xslt')))
  hsh = Nori.new(:parser => :nokogiri).parse(sams_log.transform(doc).to_xml).to_hash
  hsh = self.nested_transform(hsh)
  #puts hsh
  a = {"sams" => hsh["log"]}
  return a
end

def self.batch(path)
  a = self.to_hash(path)
  index = "elabbook";type = "sams";id = a["sams"]["sample"]

  batch = [
    {"index" => {"_index" => index, "_type" => type, "_id" => id}}.to_json,
    a["sams"].to_json,
    ""
  ].join("\n")
end

def self.to_rest(path)
  a = self.to_hash(path)
  id = a["sams"]["sample"]
  
  return {:id => id, :log => a.to_json}
end

def self.nested_transform(nested_hash={})
  nested_hash.each_pair do |key,value|
    nested_hash[key] = self.transform(key,value)
  end
end

def self.transform(key,value)
  return nested_transform(value) if value.is_a?(Hash)
  if value.is_a?(Array)
    return value.collect {|v| transform(key,v)}
  end
  
  case key
  when "sample" then value = value.to_i  
  when "concentration" then value = value.match(/(\d+).*/) {|m| m[1].to_f/1000} || 0
  when "time" then value = ISO8601::Duration.new(value).to_seconds / 60
  end
  return value
end

end