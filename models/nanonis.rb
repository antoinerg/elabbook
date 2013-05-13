class Nanonis
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
    #DateTime.iso8601(@xml.xpath('/SPM/Package/Date').first.content.gsub('.','-'))
    DateTime.iso8601('2013-05-13')
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
    @images ||= find_images
  end

  def find_images
    image_dir = File.join(self.folder,'..','img')
    # Loading images
    if File.directory?(image_dir)
      images = Dir.entries(image_dir)[2..-1].sort.select {|f| f.match("#{self.filename}.*xml$")}
        #parser = Nori.new
      images.collect! do |img_xml|
        SDFImage.new(File.join(image_dir,img_xml))
      end
    else
      images = [];
    end
  end
end
