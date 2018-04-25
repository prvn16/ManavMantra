<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#160;"> ]>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="no"/>
    
    <xsl:template match="/documentation">
        <html>
            <head>
                <xsl:variable name="docroot"><xsl:value-of select="docroot" /></xsl:variable>
                <title><xsl:value-of select="title" /></title>
                <link href="{$docroot}/includes/product/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
                <link href="{$docroot}/includes/product/css/site6.css" rel="stylesheet" type="text/css" />
                <link href="{$docroot}/includes/product/css/site6_offcanvas.css" rel="stylesheet" type="text/css" />
                <link href="{$docroot}/includes/product/css/doc_center.css" rel="stylesheet" type="text/css" />
                <link href="{$docroot}/includes/product/css/doc_center_installed.css" rel="stylesheet" type="text/css" />
                <script type="text/javascript" src="{$docroot}/includes/shared/equationrenderer/release/MathRenderer.js"></script>
            </head>
            <body>
                <div class="content_container">
                    <div class="container-fluid">
                        <div class="row">
                            <div class="col-xs-12">
                                <section id="doc_center_content">
                                    <div>
                                        <h1 class="r2017a"><xsl:value-of select="title" /></h1>
                                        <div class="doc_topic_desc">
                                            <div class="purpose_container">
                                                <p><xsl:value-of select="purpose" /></p>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="ref_sect">
                                        <h2>Syntax</h2>
                                        <div class="syntax_signature">
                                            <div class="syntax_signature_module">
                                                <xsl:apply-templates select="syntaxes/syntax" />
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="ref_sect">
                                        <h2 id="description">Description</h2>
                                        <div class="descriptions">
                                            <div class="description_module">
                                                <div class="description_element">
                                                    <div class="code_responsive">
                                                        <p>
                                                            <xsl:value-of select="description" disable-output-escaping="yes"/>
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </section>
                            </div>
                        </div>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="syntax">
        <div class="code_responsive"><code class="synopsis"><xsl:value-of select="." /></code></div>
    </xsl:template>
</xsl:transform>