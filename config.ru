#require 'shrimp'
#use Shrimp::Middleware, :cache_ttl => 3600, :out_path => "/tmp"
#require 'pdfkit'
#use PDFKit::Middleware

require './app.rb'
run Elabbook
