#!/usr/bin/ruby

require 'rubygems'
require 'rack'
require File.join(File::dirname(__FILE__),"app.rb")
 
Rack::Handler::CGI.run(Elabbook)
