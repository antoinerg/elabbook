class SPM
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

=begin HTTP_based
  def initialize(path)
    @path = path
    /^(?<folder>\/.*\/)(?<name>[^\/]*)$/ =~ path
    @folder = folder
    begin
      xml = ::Nginx.get(@path)
    rescue
      return "Can't find xml"
    end
    @xml = Nokogiri::XML(xml,&:noblanks)
  end
=end

  def datetime 
    DateTime.iso8601(@xml.xpath('/SPM/Package/Date').first.content)
  end

  def type
    @xml.xpath('/SPM/Package/Type').first.content
  end

  def format
    @xml.xpath('/SPM/Package/Format').first.content
  end

  def hash
    @hash ||= @xml.xpath('/SPM/Package/Hash').first.content
  end

  def filename
    @filename ||= @xml.at_xpath('/SPM/Package/Filename').content
  end

  def images
    @images ||= find_images
  end

  def find_images
    image_dir = File.join(self.folder,'..','img')
    # Loading images
    if File.directory?(image_dir)
      images = Dir.entries(image_dir).select {|f| f.match("#{self.filename}.*xml$")}
      images.collect! do |img_xml|
        SpmImage.new(File.join(image_dir,img_xml))
      end
    else
      images = [];
    end
  end

=begin HTTP_based
  def find_images
    image_dir = File.join(self.folder,'..','img/')
    # Loading images
    entries = ::Nginx.entries(image_dir)
    images = entries.select {|f| f["name"].match("#{self.filename}.*xml$")}
    images.collect! do |img_xml|
      SDFImage.new(img_xml)
    end
  end
=end
end
