<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#160;"> ]>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="no"/>
    
    <xsl:template match="/documentation">
        <html>
            <xsl:variable name="docroot"><xsl:value-of select="docroot" /></xsl:variable>
            <head>
                <title><xsl:value-of select="title" /></title>
                <link href="{$docroot}/includes/product/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
                <link href="{$docroot}/includes/product/css/site6.css" rel="stylesheet" type="text/css" />
                <link href="{$docroot}/includes/product/css/site6_lg.css?201703160945" rel="stylesheet" media="screen and (min-width: 1200px)"></link>
                <link href="{$docroot}/includes/product/css/site6_md.css?201703160945" rel="stylesheet" media="screen and (min-width: 992px) and (max-width: 1199px)"></link>
                <link href="{$docroot}/includes/product/css/site6_sm+xs.css?201703160945" rel="stylesheet" media="screen and (max-width: 991px)"></link>
                <link href="{$docroot}/includes/product/css/site6_sm.css?201703160945" rel="stylesheet" media="screen and (min-width: 768px) and (max-width: 991px)"></link>
                <link href="{$docroot}/includes/product/css/site6_xs.css?201703160945" rel="stylesheet" media="screen and (max-width: 767px)"></link>
                <link href="{$docroot}/includes/product/css/site6_offcanvas.css" rel="stylesheet" type="text/css" />
                <link href="{$docroot}/includes/product/css/doc_center.css" rel="stylesheet" type="text/css" />
                <link href="{$docroot}/includes/product/css/doc_center_installed.css" rel="stylesheet" type="text/css" />
                <script type="text/javascript" src="{$docroot}/includes/product/scripts/jquery/jquery-latest.js"></script>
                <script type="text/javascript" src="{$docroot}/includes/product/scripts/underscore-min.js"></script>
                <script type="text/javascript" src="{$docroot}/includes/product/scripts/suggest.js"></script>
                <script type="text/javascript" src="{$docroot}/includes/shared/equationrenderer/release/MathRenderer.js"></script>
            </head>
            <body>
                <div class="sticky_header_container includes_subnav">
                    <div class="section_header level_3">
                        <div class="container-fluid">
                            <div class="row" id="mobile_search_row">
                                <div class="col-xs-12 col-sm-6 col-sm-push-6 col-md-5 col-md-push-7" id="mobile_search">
                                    <div class="search_nested_content_container">
                                        <form id="docsearch_form" name="docsearch_form" method="get" data-release="R2017b" data-language="en" action="{$docroot}/templates/searchresults.html">
                                            <div class="input-group tokenized_search_field">
                                                <label class="sr-only">Search Help</label>
                                                <input type="text" class="form-control conjoined_search" autocomplete="off" name="qdoc" placeholder="Search Help" id="docsearch"></input>
                                                <div class="input-group-btn">
                                                    <button type="submit" name="submitsearch" id="submitsearch" class="btn icon-search btn_search_adjacent btn_search icon_16" tabindex="-1"></button>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                <button class="btn icon-remove btn_search pull-right icon_32 visible-xs" data-toggle="collapse" href="#mobile_search" aria-expanded="false" aria-controls="mobile_search"></button></div>
                                <div class="col-sm-6 col-sm-pull-6 col-md-7 col-md-pull-5" id="section_header_title">
                                    <div class="section_header_content">
                                        <div class="section_header_title">
                                            <h1><a href="{$docroot}/documentation-center.html">Documentation</a></h1>
                                        </div>
                                    </div>
                                </div>
                                <div class="visible-xs" id="search_actuator">
                                    <button class="btn icon-search btn_search pull-right icon_16" data-toggle="collapse" href="#mobile_search" aria-expanded="false" aria-controls="mobile_search"></button>
                                </div>
                            </div><!--END.CLASS row-->
                        </div><!--END.CLASS container-fluid-->
                    </div><!--END.CLASS section_header level_3-->
                </div><!--END.CLASS sticky_header_container-->

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