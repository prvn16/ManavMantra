function writeFPTDataToPartFile(partsFileName, parameter, value)
% WRITEFPTDATATOPARTSFILE Stores the parameter and its value in the
% preferences section of the FPT parts file in the model SLX file

% Copyright 2014 The MathWorks, Inc.

doesExist = isequal(exist(partsFileName, 'file'),2);
if ~doesExist
    xmlDocument = com.mathworks.xml.XMLUtils.createDocument('FPTSettings');
    settingRoot = xmlDocument.getDocumentElement;
else
    xmlDocument = xmlread(partsFileName);
    settingRoot = xmlDocument.getDocumentElement;
end
    
if ~iscell(parameter)
    locWriteContent(xmlDocument, settingRoot, parameter, value);
else
    for i = 1:numel(parameter)
        locWriteContent(xmlDocument, settingRoot, parameter{i}, value{i});
    end    
end
xmlwrite(partsFileName, xmlDocument);

end
%-------------------------------------------------------------------
function locWriteContent(xmlDocument,settingRoot, parameter, value)

valueClass = class(value);
if ~ischar(value)
    value = sprintf('%d',value);
end
propNode = settingRoot.getElementsByTagName(parameter);
if isempty(propNode) || propNode.getLength < 1
    propNode = xmlDocument.createElement(parameter);
    propNode.appendChild(xmlDocument.createTextNode(value));
    classNode = xmlDocument.createElement([parameter 'Class']);
    classNode.appendChild(xmlDocument.createTextNode(valueClass));
    settingRoot.appendChild(propNode);
    settingRoot.appendChild(classNode);
else
    thisNode = propNode.item(0);
    valueNode = thisNode.getFirstChild;
    valueNode.setData(value);
end
end
