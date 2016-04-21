module HelperModule
    def load_xml(p)
      xml_path = path(p)
      if File.exist?(xml_path)
        xml = Nokogiri::XML(File.read(xml_path),&:noblanks)
      end
      return xml
    end

    def list_file(path)
      return Dir.entries(path).sort[2..-1].collect {|f| File.join(path,f).gsub(/^#{$settings_dir.chomp('/')}/,'')}
    end

    def path(url=request.fullpath)
      root = $settings_dir
      path = File.join(root,url)
    end

    def url(filepath)
      "/" + filepath.gsub(/^#{$settings_dir}/,'')
    end

    def url_cdn(p)
      $settings_file_server + p.gsub(/^#{$settings_dir}/,'')
    end

    def svg_tag(image,html_class='')
      html = []
      html << "<figure class='#{html_class}'>"
      html << "<figcaption>#{image.title}</figcaption>"
      url = url_cdn(image.svg_path)
      html << "<object type='image/svg+xml' data='#{url}'></object><a class='noprint' href='#{url}'>Download</a>"

      html << "</figure>"
      html.join("\n")
    end

    def png_tag(image,html_class='')
      html = []
      html << "<figure class='#{html_class}'>"
      html << "<figcaption>#{image.title}</figcaption>"
      url = url_cdn(image.png_path)
      html << "<a href='#{url}'><img style='width:100%' src='#{url}'/></a>"
      html << "</figure>"
      html.join("\n")
    end
end
