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
    @images ||= find_images
  end

  def title
    @xml.at_xpath('/log/title').content rescue ""
  end

  def id
    @xml.at_xpath('/log/sample').content rescue ""
  end

  def datetime 
    DateTime.iso8601(@xml.xpath('/log/date').first.content)
  end

  def find_images
    image_dir = File.join(self.folder,'img')
    # Loading images
    if File.directory?(image_dir)
      images = Dir.entries(image_dir)[2..-1].sort.select {|f| f.match(".*xml$")}
      images.collect! do |img_xml|
        SDFImage.new(File.join(image_dir,img_xml))
      end
    else
      images = [];
    end
  end
end
