class Nanonis < SPM
  def datetime 
    @datetime ||= DateTime.parse(@xml.xpath('/SPM/Package/Date').first.content)
  end

  def find_images_in(path)
    image_dir = File.join(self.folder,path)
    # Loading images
    if File.directory?(image_dir)
      images = Dir.entries(image_dir).select {|f| f.match(".*xml$")}
      images.collect! do |img_xml|
        SpmImage.new(File.join(image_dir,img_xml))
      end
    else
      images = [];
    end
    return images
  end

  def find_images
    image_dir = File.join(self.folder,'..','img',self.filename)
    # Loading images
    if File.directory?(image_dir)
      images = Dir.entries(image_dir).select {|f| f.match(".*xml$")}
      images.collect! do |img_xml|
        SpmImage.new(File.join(image_dir,img_xml))
      end
    else
      images = [];
    end
  end

  def oscillation_amplitude
    xml.at_xpath('/SPM/UserData/oscillation/amplitude') ||
    xml.at_xpath('/SPM/Package/Header/oscillation_control_amplitude_setpoint__m_') || 
    '#'
  end

  def q_factor
    begin
      xml.at_xpath('/SPM/UserData/cantilever/qfactor') ||
      xml.xpath('/SPM/Package/Header/oscillation_control_pll_setup_q_factor') || 
      xml.at_xpath('/SPM/Package/Header/q')[0] ||
      '#'
    rescue
      '#'
    end
  end
end
