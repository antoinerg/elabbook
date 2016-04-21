<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xsl" version="1.0"
	xmlns:my="http://nokogiri.org/antoine" extension-element-prefixes="my">
  <!-- identity template -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="step">
	<xsl:element name="step_{@id}">
		<xsl:copy>
	      <xsl:apply-templates select="@*|node()"/>
	    </xsl:copy>
	</xsl:element>
  </xsl:template>

  <xsl:template match="concentration">
	<xsl:copy>
		<xsl:value-of select="my:concentration(.)"/>
	</xsl:copy>
  </xsl:template>
</xsl:stylesheet>