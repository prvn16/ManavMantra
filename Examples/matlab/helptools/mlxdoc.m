function mlxdoc(topic)
%mlxdoc Opens a live script documentation .
%   mlxdoc(topic) opens the documentation in help browser after reading the documentation from live script file.
%   Copyright 2017 The MathWorks, Inc. 
    dom = getDocXml(topic);
    xsltfile = fullfile(fileparts(mfilename('fullpath')),'private','mlxdoc.xsl');
    html = xslt(dom, xsltfile, '-tostring');
    web(['text://' html], '-helpbrowser');
end

function dom = getDocXml(topic)
  % Read the xml string directly into an XML model object
    xmlString = helpUtils.getDocumentationXML(topic);
    inputObject = org.xml.sax.InputSource(java.io.StringReader(xmlString));     
    dom = xmlread(inputObject);
    % Since MATLAB's xslt function does not support XSL parameters, 
    % add the docroot element to the DOM instead.
    docrootElt = dom.createElement('docroot');
    docrootText = dom.createTextNode(docroot);
    docrootElt.appendChild(docrootText);
    dom.getDocumentElement.appendChild(docrootElt);
end
