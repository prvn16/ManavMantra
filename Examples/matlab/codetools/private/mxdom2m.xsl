<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<!--
This is an XSL stylesheet which converts MX files into M.
Use the XSLT command to perform the conversion.

Matthew J. Simoneau
Copyright 1984-2002 The MathWorks, Inc.
  
-->
                
  <xsl:output method="text"/>


  <xsl:template match="/">
    <xsl:for-each select="//cell">%%
<xsl:call-template name="break"/>
      <xsl:text xml:space="preserve">

</xsl:text>
      <xsl:value-of select="mcode"/>
      <xsl:text xml:space="preserve">


</xsl:text>
    </xsl:for-each>
  </xsl:template>



  <xsl:template name="break">
    <xsl:param name="text" select="text"/>% <xsl:choose>
      <xsl:when test="contains($text, '&#xa;')">
        <xsl:value-of select="substring-before($text, '&#xa;')"/>
      <xsl:text xml:space="preserve">
</xsl:text>
<xsl:call-template name="break"><xsl:with-param name="text" select="substring-after($text,'&#xa;')"/></xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
