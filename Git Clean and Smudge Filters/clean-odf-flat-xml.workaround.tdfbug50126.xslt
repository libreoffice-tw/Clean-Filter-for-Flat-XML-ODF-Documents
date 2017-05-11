<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output encoding="UTF-8"/>

	<xsl:template match="/*">
		<office:document>
			<xsl:for-each-group select="Line" group-by="ItemID | ITEMID">
				<xsl:sequence select="."/>
			</xsl:for-each-group>
		</office:document>
	</xsl:template>
</xsl:stylesheet>
