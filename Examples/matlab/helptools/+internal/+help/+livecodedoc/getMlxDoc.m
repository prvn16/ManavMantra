function html = getMlxDoc(topic)
    if helpUtils.isLiveFunctionAndHasDocumentation(topic)
        dom = getDocXml(topic);
        xsltfile = fullfile(fileparts(mfilename('fullpath')),'private','mlxdoc.xsl');
        html = xslt(dom, xsltfile, '-tostring');
    else
        html = '';
    end
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
