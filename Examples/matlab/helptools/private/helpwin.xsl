<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
This is an XSL stylesheet which creates HTML-formatted M-file help.

Copyright 2008 The MathWorks, Inc.
  
-->
<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#160;"> ]>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes"/>

    <xsl:template match="/help-info">
        <xsl:variable name="title">
            <xsl:if test="count(help-topic) &gt; 1">
                <xsl:value-of select="title" />
            </xsl:if>
            <xsl:if test="count(help-topic) = 1">
                <xsl:value-of select="help-topic/title" />
            </xsl:if>
        </xsl:variable>

        <html>
            <head>
                <xsl:element name="link">
                    <xsl:attribute name="rel">stylesheet</xsl:attribute>
                    <xsl:attribute name="href"><xsl:value-of select="helptools-dir" />/private/helpwin.css</xsl:attribute>
                </xsl:element>
                <title><xsl:value-of select="$title" /></title>
            </head>
            <body>
                <xsl:if test="count(help-topic) &gt; 1">
                    <!-- Handle multi-page help -->
                    <xsl:comment>Multi-page help</xsl:comment>
                    <table border="0" cellspacing="0" width="100%">
                        <tr class="subheader">
                            <td class="headertitle"><xsl:value-of select="title" /></td>
                        </tr>
                    </table>
                    <div class="topiclinks">
                        <xsl:for-each select="help-topic">
                            <xsl:element name="a">
                                <xsl:attribute name="href"><xsl:value-of select="../filename" />#topic<xsl:value-of select="@id" /></xsl:attribute>
                                <xsl:attribute name="class">topiclink</xsl:attribute>
                                <xsl:value-of select="topic" />
                            </xsl:element>
                        </xsl:for-each>
                    </div>
                    <xsl:apply-templates select="help-topic" mode="multi-topic" />
                </xsl:if>

                <!-- Handle single-page help -->
                <xsl:if test="count(help-topic) = 1">
                    <!-- Display a message if the documentation is not installed. -->
                    <xsl:if test="@doc-installed='false'">
                        <xsl:comment>Doc not installed warning</xsl:comment>
                        <table><tr>
                            <td width="5%">
                                <xsl:element name="img">
                                    <xsl:attribute name="src"><xsl:value-of select="warning-image" /></xsl:attribute>
                                </xsl:element>
                            </td>
                            <td bgcolor="ffffco"><font size="+3"><b>Warning - Documentation Files Not Found</b></font></td>
                        </tr></table>

                        <p>
                            MATLAB cannot find your HTML help documents based on your current <b>Documentation location</b> setting.  Click
                            <xsl:element name="a">
                                <xsl:attribute name="href"><xsl:value-of select="error-page" /></xsl:attribute>
                                here
                            </xsl:element>
                            for more information.
                            The MATLAB file help for <span class="helptopic"><xsl:value-of select="help-topic/topic" /></span> appears below.
                        </p>
                    </xsl:if>

                    <xsl:comment>Single-page help</xsl:comment>
                    <xsl:apply-templates select="help-topic" mode="single-topic" />
                </xsl:if>
            </body>
        </html>
    </xsl:template>

    <!-- Template used to generate HTML for single-topic help -->
    <xsl:template match="help-topic" mode="single-topic">
        <table border="0" cellspacing="0" width="100%">
            <tr class="subheader">
                <td class="headertitle"><xsl:value-of select="title" /></td>
                <xsl:for-each select="headers/header">
                    <td>
                        <xsl:attribute name="class">subheader-<xsl:if 
                            test="position() != last()">left</xsl:if><xsl:if 
                            test="position() = last()">right</xsl:if>
                        </xsl:attribute>
                        <xsl:if test="./action">
                            <xsl:element name="a">
                                <xsl:attribute name="href">matlab:<xsl:value-of select="action" /></xsl:attribute>
                                <xsl:value-of select="text" />
                            </xsl:element>
                        </xsl:if>
                        <xsl:if test="not(./action)">
                            <xsl:value-of select="text" />
                        </xsl:if>
                    </td>
                </xsl:for-each>
            </tr>
        </table>
        <div class="title">
            <xsl:value-of select="topic" />
        </div>
        <xsl:if test="@helpfound='true'">
            <xsl:call-template name="helptext">
                <xsl:with-param name="id" select="@id" />
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="@helpfound='false'">
            <xsl:comment>No help found</xsl:comment>
            <p>No help found for <span class="helptopic"><xsl:value-of select="topic" /></span>.</p>
            <p>
                <xsl:element name="a">
                    <xsl:attribute name="href">matlab:docsearch('<xsl:value-of select="escaped-topic" />')</xsl:attribute>
                    Search for <b><xsl:value-of select="topic" /></b> in documentation
                </xsl:element>
            </p>
        </xsl:if>
        <xsl:apply-templates select="class-info" />
        <xsl:apply-templates select="method-info" mode="detail" />
        <xsl:apply-templates select="property-info" mode="detail" />
        <xsl:apply-templates select="event-info" mode="detail" />
        <xsl:apply-templates select="enumeration-info" mode="detail" />
    </xsl:template>

    <!-- Template used to generate HTML for multi-topic help -->
    <xsl:template match="help-topic" mode="multi-topic">
        <hr />
        <xsl:comment>Topic: <xsl:value-of select="topic" /></xsl:comment>
        <xsl:element name="a">
            <xsl:attribute name="name">topic<xsl:value-of select="@id" /></xsl:attribute>
        </xsl:element>
        <div class="title"><xsl:value-of select="topic" /></div>
        <xsl:call-template name="helptext">
            <xsl:with-param name="id" select="@id" />
        </xsl:call-template>
    </xsl:template>

    <!-- Inserts the placeholder comment for the actual help text. -->
    <xsl:template name="helptext">
        <xsl:param name="id" />
        <div class="helptext"><pre>
            <xsl:comment>helptext <xsl:value-of select="$id" /></xsl:comment>
        </pre></div>
        <xsl:comment>after help <xsl:value-of select="$id" /></xsl:comment>
    </xsl:template>

    <!-- Creates the output for classes. -->
    <xsl:template match="class-info">
        <xsl:comment>Class</xsl:comment>
        <div class="sectiontitle">Class Details</div>
        <table class="class-details">
            <xsl:if test="super-classes">
                <tr>
                    <td class="class-detail-label">Superclasses</td>
                    <td>
                        <xsl:for-each select="super-classes/super-class">
                            <xsl:if test="position() != 1">, </xsl:if>
                            <xsl:element name="a">
                                <xsl:attribute name="href">matlab:<xsl:value-of select="/help-info/help-command-option" />('<xsl:value-of select="@name" />')</xsl:attribute>
                                <xsl:value-of select="@name" />
                            </xsl:element>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:if>
            <tr><td class="class-detail-label">Sealed</td><td><xsl:value-of select="@sealed" /></td></tr>
            <tr><td class="class-detail-label">Construct on load</td><td><xsl:value-of select="@constructonload" /></td></tr>
        </table>

        <xsl:if test="constructors">
            <xsl:comment>Constructors</xsl:comment>
            <div class="sectiontitle"><a name="constructors" />Constructor Summary</div>
            <table class="summary-list">
                <xsl:apply-templates select="constructors/constructor-info" mode="summary" />
            </table>
        </xsl:if>

        <xsl:if test="enumeration">
            <xsl:comment>Enumeration</xsl:comment>
            <div class="sectiontitle"><a name="enumeration" />Enumeration Summary</div>
            <table class="summary-list">
                <xsl:apply-templates select="enumeration/enumeration-info" mode="summary" />
            </table>
        </xsl:if>

        <xsl:if test="properties">
            <xsl:comment>Properties</xsl:comment>
            <div class="sectiontitle"><a name="properties" />Property Summary</div>
            <table class="summary-list">
                <xsl:apply-templates select="properties/property-info" mode="summary" />
            </table>
        </xsl:if>

        <xsl:if test="methods">
            <xsl:comment>Methods</xsl:comment>
            <div class="sectiontitle"><a name="methods" />Method Summary</div>
            <table class="summary-list">
                <xsl:apply-templates select="methods/method-info" mode="summary" />
            </table>
        </xsl:if>

        <xsl:if test="events">
            <xsl:comment>Events</xsl:comment>
            <div class="sectiontitle"><a name="events" />Event Summary</div>
            <table class="summary-list">
                <xsl:apply-templates select="events/event-info" mode="summary" />
            </table>
        </xsl:if>

    </xsl:template>
    <xsl:variable name="className">
        <xsl:value-of select="/help-info/help-topic/class-info/@name" />
    </xsl:variable>

    <!-- Summary table for class constructors -->
    <xsl:template match="constructor-info" mode="summary">
        <tr class="summary-item">
            <td class="name">
                <xsl:element name="a"><xsl:attribute name="href">matlab:<xsl:value-of select="/help-info/help-command-option" />('<xsl:value-of select="$className" />.<xsl:value-of select="@name" />')</xsl:attribute>
                <xsl:value-of select="@name" /></xsl:element>
            </td>
            <td class="m-help">
                <xsl:if test="h1-line"><xsl:value-of select="h1-line" disable-output-escaping="yes" /></xsl:if>
                <xsl:if test="not(m-help)">&nbsp;</xsl:if>
            </td>
        </tr>
    </xsl:template>

    <!-- Summary table for class properties -->
    <xsl:template match="property-info" mode="summary">
        <xsl:if test="@hidden='false'">
            <tr class="summary-item">
                <td class="name">
                    <xsl:element name="a"><xsl:attribute name="href">matlab:<xsl:value-of select="/help-info/help-command-option" />('<xsl:value-of select="$className" />.<xsl:value-of select="@name" />')</xsl:attribute>
                    <xsl:value-of select="@name" /></xsl:element>
                </td>
                <td class="m-help">
                    <xsl:if test="h1-line"><xsl:value-of select="h1-line" disable-output-escaping="yes" /></xsl:if>
                    <xsl:if test="not(m-help)">&nbsp;</xsl:if>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <!-- Summary table for class events -->
    <xsl:template match="event-info" mode="summary">
        <xsl:if test="@hidden='false'">
            <tr class="summary-item">
                <td class="name">
                    <xsl:element name="a"><xsl:attribute name="href">matlab:<xsl:value-of select="/help-info/help-command-option" />('<xsl:value-of select="$className" />.<xsl:value-of select="@name" />')</xsl:attribute>
                    <xsl:value-of select="@name" /></xsl:element>
                </td>
                <td class="m-help">
                    <xsl:if test="h1-line"><xsl:value-of select="h1-line" disable-output-escaping="yes" /></xsl:if>
                    <xsl:if test="not(m-help)">&nbsp;</xsl:if>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <!-- Summary table for class enumeration -->
    <xsl:template match="enumeration-info" mode="summary">
        <tr class="summary-item">
            <td class="name">
                <xsl:element name="a"><xsl:attribute name="href">matlab:<xsl:value-of select="/help-info/help-command-option" />('<xsl:value-of select="$className" />.<xsl:value-of select="@name" />')</xsl:attribute>
                <xsl:value-of select="@name" /></xsl:element>
            </td>
            <td class="m-help">
                <xsl:if test="h1-line"><xsl:value-of select="h1-line" disable-output-escaping="yes" /></xsl:if>
                <xsl:if test="not(m-help)">&nbsp;</xsl:if>
            </td>
        </tr>
    </xsl:template>

    <!-- Summary table for class methods -->
    <xsl:template match="method-info" mode="summary">
        <xsl:if test="@hidden='false'">
            <tr class="summary-item">
                <td class="attributes">
                    <xsl:if test="not(@access='public')">
                        <xsl:value-of select="@access" /><xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:if test="@static='true'">Static<xsl:text> </xsl:text></xsl:if>
                    <xsl:if test="@abstract='true'">Abstract<xsl:text> </xsl:text></xsl:if>
                    <xsl:if test="@sealed='true'">Sealed<xsl:text> </xsl:text></xsl:if>
                    &nbsp;
                </td>
                <td class="name">
                    <xsl:element name="a"><xsl:attribute name="href">matlab:<xsl:value-of select="/help-info/help-command-option" />('<xsl:value-of select="$className" />.<xsl:value-of select="@name" />')</xsl:attribute>
                    <xsl:value-of select="@name" />
                    </xsl:element>
                </td>
                <td class="m-help">
                    <xsl:if test="h1-line"><xsl:value-of select="h1-line" disable-output-escaping="yes" /></xsl:if>
                    <xsl:if test="not(m-help)">&nbsp;</xsl:if>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <!-- Method details -->
    <xsl:template match="method-info" mode="detail">
        <xsl:comment>Method</xsl:comment>
        <div class="sectiontitle">Method Details</div>
        <table class="class-details">
            <xsl:if test="@definingclass">
                <tr><td class="class-detail-label">Defining Class</td><td><xsl:value-of select="@definingclass" /></td></tr>
            </xsl:if>
            <tr><td class="class-detail-label">Access</td><td><xsl:value-of select="@access" /></td></tr>
            <tr><td class="class-detail-label">Sealed</td><td><xsl:value-of select="@sealed" /></td></tr>
            <tr><td class="class-detail-label">Static</td><td><xsl:value-of select="@static" /></td></tr>
        </table>
    </xsl:template>

    <!-- Property details -->
    <xsl:template match="property-info" mode="detail">
        <xsl:comment>Property</xsl:comment>
        <div class="sectiontitle">Property Details</div>
        <table class="class-details">
            <tr><td class="class-detail-label">Constant</td><td><xsl:value-of select="@constant" /></td></tr>
            <tr><td class="class-detail-label">Dependent</td><td><xsl:value-of select="@dependent" /></td></tr>
            <tr><td class="class-detail-label">Sealed</td><td><xsl:value-of select="@sealed" /></td></tr>
            <tr><td class="class-detail-label">Transient</td><td><xsl:value-of select="@transient" /></td></tr>
            <tr><td class="class-detail-label">GetAccess</td><td><xsl:value-of select="@getaccess" /></td></tr>
            <tr><td class="class-detail-label">SetAccess</td><td><xsl:value-of select="@setaccess" /></td></tr>
            <tr><td class="class-detail-label">GetObservable</td><td><xsl:value-of select="@getobservable" /></td></tr>
            <tr><td class="class-detail-label">SetObservable</td><td><xsl:value-of select="@setobservable" /></td></tr>
        </table>
    </xsl:template>

    <!-- Event details -->
    <xsl:template match="event-info" mode="detail">
        <xsl:comment>Event</xsl:comment>
        <div class="sectiontitle">Event Details</div>
        <table class="class-details">
            <tr><td class="class-detail-label">ListenAccess</td><td><xsl:value-of select="@listenaccess" /></td></tr>
            <tr><td class="class-detail-label">NotifyAccess</td><td><xsl:value-of select="@notifyaccess" /></td></tr>
        </table>
    </xsl:template>

    <!-- Enumeration details -->
    <xsl:template match="enumeration-info" mode="detail">
        <xsl:comment>Enumeration</xsl:comment>
        <div class="sectiontitle">Enumeration Details</div>
        <table class="class-details">
        </table>
    </xsl:template>

</xsl:transform>