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
      @xml.at_xpath('/Figure/Direction').content rescue ''
  end

  def path
    @svg_path
  end

  def title
    @xml.at_xpath('/Figure/Title').content rescue ''
  end
end
