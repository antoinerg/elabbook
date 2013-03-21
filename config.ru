#require 'shrimp'
#use Shrimp::Middleware, :cache_ttl => 3600, :out_path => "/tmp", :margin => '0cm', :format => 'A4'
#require 'pdfkit'
#use PDFKit::Middleware

require './app.rb'
run Elabbook
