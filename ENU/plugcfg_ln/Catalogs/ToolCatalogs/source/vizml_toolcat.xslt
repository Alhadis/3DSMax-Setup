<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
		<xsl:template match="Scene">
		<Catalog>
			<ItemID >
				<xsl:attribute name="idValue" >
						<xsl:value-of select="@id"></xsl:value-of>
				</xsl:attribute>
			</ItemID>
			<Properties>
				<AccessRight>2</AccessRight>
				<ItemName> <xsl:value-of select="@Filename"></xsl:value-of>
				</ItemName>
				<Description></Description>
			</Properties>

			<Palettes>
				<xsl:apply-templates select="ObjectModifiers"></xsl:apply-templates>
			</Palettes>
		</Catalog>
		</xsl:template>
		
		<xsl:template match="ObjectModifiers">
			<xsl:apply-templates select="Materials"></xsl:apply-templates>
		</xsl:template>
		
		<xsl:template match="Materials">
		<Palette>
			<ItemID >
				<xsl:attribute name="idValue" >
				<xsl:value-of select="@id"></xsl:value-of>
				</xsl:attribute>
			</ItemID>
			<Properties>
				<AccessRight>2</AccessRight>
				<ItemName> <xsl:value-of select="//*/@Filename"></xsl:value-of> - materials</ItemName>
				<Description></Description>
			</Properties>

			<Tools>
			<xsl:apply-templates select="Material"></xsl:apply-templates>
			</Tools>
		</Palette>
		</xsl:template>
		<xsl:template match="Material">
				<Tool>
					<ItemID >
						<xsl:attribute name="idValue" >
						<xsl:value-of select="@id"></xsl:value-of>
						</xsl:attribute>
					</ItemID>
					<Properties>
						<ItemName> 
							<!-- select all child node  name attributes and use the value of the first -->
							<xsl:value-of select="./*/@name"></xsl:value-of>
						 </ItemName>
						<Description></Description>
						<Help Link="Help" HREF="http://"/>
						<Images>
							<Image cx="88" cy="88">
								<xsl:attribute name="src" >
								<xsl:value-of select="@thumbnail"></xsl:value-of>
								</xsl:attribute>
							</Image>
						</Images> 
						<ToolTip>
							<xsl:value-of select="./*/@name"></xsl:value-of>
						</ToolTip>
						<Keywords></Keywords>
						<AccessRight>2</AccessRight>
					</Properties>
					<StockToolRef idValue="E04B3676-CBB7-454c-9CDB-A55ACA81C41F">
					</StockToolRef>
					<Data>
						<xsl:copy-of select="."></xsl:copy-of>
					</Data>
					</Tool>
		</xsl:template>
</xsl:stylesheet>
