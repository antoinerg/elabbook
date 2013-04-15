class Sample
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

  def images
    @images ||= SDFImage.find_by_sdf(self)
  end

  def title
    @xml.at_xpath('/log/title').content
  end

  def datetime 
    DateTime.iso8601(@xml.xpath('/log/date').first.content)
  end
end
