<?xml version="1.0" ?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:env="http://www.w3.org/1999/xhtml">

 
	<xsl:param name="xhtmlfile">file:///tmp/test.xhtml</xsl:param>

	<xsl:output method="html" encoding="UTF-8" indent="yes" />

	<xsl:template match="/env:html/env:body//env:article">
		<xsl:element
			namespace="http://www.w3.org/1999/xhtml"
			name="article">
			<xsl:comment>ADOC XML file <xsl:value-of select="$xhtmlfile"/></xsl:comment>
			<xsl:apply-templates select="document($xhtmlfile)/env:html/env:body[@class='article']/*"/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
