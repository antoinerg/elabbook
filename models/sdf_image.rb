class SDFImage
  attr_reader :xml, :xml_path, :svg_path, :png_path

  def initialize(path)
    @xml_path = path
    if File.exist?(@xml_path)
      @xml = Nokogiri::XML(File.read(@xml_path),&:noblanks)
      @svg_path = File.join(File.dirname(@xml_path),@xml.at_xpath("/Figure/@filename"))
      @png_path = File.join(File.dirname(@xml_path),@xml.at_xpath("/Figure/@pngfilename") || "")
    else
	raise StandardError, "Can't find XML file"
    end
  end

  def direction
    begin
      @xml.at_xpath('/Figure/Direction').content
    rescue
      ''
    end
  end

  def path
    @svg_path
  end

  def title
    @xml.at_xpath('/Figure/Title').content
  end

  def self.find_by_sdf(sdf)
    image_dir ||= File.join(sdf.folder,'..','img')
	  # Loading images
	  if File.directory?(image_dir)
	  	images = Dir.entries(image_dir)[2..-1].sort.select {|f| f.match("#{sdf.filename}.*xml$")}
	    	#parser = Nori.new
  		images.collect! do |img_xml|
  			self.new(File.join(image_dir,img_xml))
  		end
	  else
		  images = [];
	  end
  end
end
