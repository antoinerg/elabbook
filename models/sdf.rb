class SDF
  attr_reader :folder, :path, :xml
  def initialize(xml_path)
    @path = xml_path
    @folder = File.dirname(@path)
    if File.exist?(@path)
      @xml = Nokogiri::XML(File.read(@path),&:noblanks)
    else
      raise StandardError, "Can't find XML file"
    end
  end

  def datetime 
    DateTime.iso8601(@xml.xpath('/SPM/Package/Date').first.content)
  end

  def type
    @xml.xpath('/SPM/Package/Type').first.content
  end

  def hash
    @xml.xpath('/SPM/Package/Hash').first.content
  end

  def filename
    @xml.at_xpath('/SPM/Package/Filename').content
  end

  def images
    @images ||= SDFImage.find_by_sdf(self)
  end
end
