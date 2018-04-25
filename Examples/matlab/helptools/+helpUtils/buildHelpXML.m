function xmlFilePath = buildHelpXML(helpContainer, outputDirPath)
% HELPUTILS.BUILDHELPXML - creates a XML file containing help comments for a MATLAB file.
% BUILDHELPXML reads help comments stored in HELPCONTAINER and generates an
% XML file in the folder specified by OUTPUTDIRPATH.
%
% BUILDHELPXML returns the full file path to the newly generated XML file.
%
% Example:
% The code below generates an XML file storing the help comments for the
% classdef RandStream.m
%
% helpContainer = ...
% matlab.internal.language.introspective.containers.HelpContainerFactory.create(which('RandStream'));
% xmlFilePath = helpUtils.buildHelpXML(helpContainer, pwd);

% Copyright 2008-2015 The MathWorks, Inc.
    narginchk(1, 2);
    
    fileName = helpContainer.mFileName;

    if nargin < 2
        outputDirPath = fileparts(helpContainer.mFilePath);
    end
    
    xmlFilePath = fullfile(outputDirPath, [fileName '.xml']);
        
    dom = com.mathworks.xml.XMLUtils.createDocument('help-topic');
    
    docRootNode = dom.getDocumentElement;

    mainHelpNode = appendChildNode(dom, docRootNode, 'mainHelp', helpContainer.getHelp);
    
    % if class, add properties/method help data
    if helpContainer.isClassHelpContainer
        classXmlObj = helpUtils.class2xml(helpContainer);
        classXmlObj.buildClassXml(dom, docRootNode);
        fileType = 'classHelp';
    else
        fileType = 'singleHelp';
    end

    mainHelpNode.setAttribute('fileType', fileType);
    
    copyrightStr = helpContainer.getCopyrightText();
    
    if ~isempty(copyrightStr)
        % Save the copyright in a node
        appendChildNode(dom, docRootNode, 'copyright', copyrightStr);
    end
    
    xmlwrite(xmlFilePath, dom);    
end

function childNode = appendChildNode(dom, parentNode, nodeName, textContent)
    % APPENDCHILDNODE - helper function to append a new child node with
    % specified text content to input parent node.
    childNode = dom.createElement(nodeName);
    
    childNode.setTextContent(textContent);
    
    parentNode.appendChild(childNode);    
end
