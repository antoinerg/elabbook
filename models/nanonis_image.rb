class NanonisImage < SPM
  def datetime 
    DateTime.parse(@xml.xpath('/SPM/Package/Date').first.content)
  end
end
