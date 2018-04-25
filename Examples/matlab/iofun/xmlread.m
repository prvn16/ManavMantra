function [parseResult,p] = xmlread(filename,varargin)
%XMLREAD  Parse an XML document and return a Document Object Model node.
%   DOMNODE = XMLREAD(FILENAME) reads a URL or file name in the character vector
%   input argument FILENAME.  The function returns DOMNODE, a Document Object Model
%   (DOM) node representing the parsed document. The node can be manipulated by using
%   standard DOM functions.
%
%   Note: A properly parsed document will display to the screen as
%
%     >> xDoc = xmlread(...)
%
%     xDoc =
%
%     [#document: null]
%
%   Example 1: All XML files have a single root element.  Some XML files declare a
%   preferred schema file as an attribute of this element.
%
%     xDoc = xmlread(fullfile(matlabroot,'toolbox/matlab/general/info.xml'));
%     xRoot = xDoc.getDocumentElement;
%     schemaURL = char(xRoot.getAttribute('xsi:noNamespaceSchemaLocation'))
%
%   Example 2: Each info.xml file on the MATLAB path contains several <listitem>
%   elements with a <label> and <callback> element. This script finds the callback
%   that corresponds to the label 'Plot Tools'.
%
%     infoLabel = 'Plot Tools';  infoCbk = '';  itemFound = false;
%     xDoc = xmlread(fullfile(matlabroot,'toolbox/matlab/general/info.xml'));
%
%     % Find a deep list of all <listitem> elements.
%     allListItems = xDoc.getElementsByTagName('listitem');
%
%     %Note that the item list index is zero-based.
%     for i=0:allListItems.getLength-1
%         thisListItem = allListItems.item(i);
%         childNode = thisListItem.getFirstChild;
%
%         while ~isempty(childNode)
%             %Filter out text, comments, and processing instructions.
%             if childNode.getNodeType == childNode.ELEMENT_NODE
%                 %Assume that each element has a single org.w3c.dom.Text child
%                 childText = char(childNode.getFirstChild.getData);
%                 switch char(childNode.getTagName)
%                     case 'label' ; itemFound = strcmp(childText,infoLabel);
%                     case 'callback' ; infoCbk = childText;
%                 end
%             end
%             childNode = childNode.getNextSibling;
%         end
%         if itemFound break; else infoCbk = ''; end
%     end
%     disp(sprintf('Item "%s" has a callback of "%s".',infoLabel,infoCbk))
%
%   See also XMLWRITE, XSLT.

%   Copyright 1984-2016 The MathWorks, Inc.

% Advanced use:
%   Note that FILENAME can also be an InputSource, File, or InputStream object
%   DOMNODE = XMLREAD(FILENAME,...,P,...) where P is a DocumentBuilder object
%   DOMNODE = XMLREAD(FILENAME,...,'-validating',...) will create a validating
%             parser if one was not provided.
%   DOMNODE = XMLREAD(FILENAME,...,ER,...) where ER is an EntityResolver will
%             will set the EntityResolver before parsing
%   DOMNODE = XMLREAD(FILENAME,...,EH,...) where EH is an ErrorHandler will
%             will set the ErrorHandler before parsing
%   [DOMNODE,P] = XMLREAD(FILENAME,...) will return a parser suitable for passing
%             back to XMLREAD for future parses.
%   

p = locGetParser(varargin);
locSetEntityResolver(p,varargin);
locSetErrorHandler(p,varargin);

if ischar(filename)
    filename = xmlstringinput(filename,true);
    % This strips off the extra stuff in the resolved file. Then,
    % we are going to use java to put it in the right form.
    if strncmp(filename, 'file:', 5)
        filename = regexprep(filename, '^file:///(([a-zA-Z]:)|[\\/])','$1');
        filename = strrep(filename, 'file://', '');
        fileObj = java.io.File(filename);
    else
        % http: doesn't work with java.io.File.
        % Xerces accepts strings which works for http://.
        fileObj = org.xml.sax.InputSource(filename);
    end   
elseif isa(filename,'java.io.File')
    % Xerces is happier when UNC filepaths are sent as a
    % FileReader/InputSource than a File object
    % Note that FileReader(String) is also valid
    if filename.exists
        fileObj = org.xml.sax.InputSource(java.io.FileReader(filename));
    else
        error(message('MATLAB:xml:FileNotFound', char(filename)));
    end
elseif isa(filename,'org.xml.sax.InputSource') || ...
        isa(filename,'java.io.InputStream')
    % noop - DocumentBuilder.parse accepts all these data types directly,
    % so we don't need to alter the input if it is one of these classes
    fileObj = filename;
else
    error(message('MATLAB:xmlread:InvalidInput'));
end

parseResult = p.parse(fileObj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = locGetParser(args)

p = [];
for i=1:length(args)
    if isa(args{i},'javax.xml.parsers.DocumentBuilderFactory')
        javaMethod('setValidating',args{i},locIsValidating(args));
        p = javaMethod('newDocumentBuilder',args{i});
        break;
    elseif isa(args{i},'javax.xml.parsers.DocumentBuilder')
        p = args{i};
        break;
    end
end

if isempty(p)
    parserFactory = javaMethod('newInstance',...
        'javax.xml.parsers.DocumentBuilderFactory');
        
    javaMethod('setValidating',parserFactory,locIsValidating(args));
    %javaMethod('setIgnoringElementContentWhitespace',parserFactory,1);
    %ignorable whitespace requires a validating parser and a content model
    p = javaMethod('newDocumentBuilder',parserFactory);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=locIsValidating(args)

tf=any(strcmp(args,'-validating'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locSetEntityResolver(p,args)

for i=1:length(args)
    if isa(args{i},'org.xml.sax.EntityResolver')
        p.setEntityResolver(args{i});
        break;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locSetErrorHandler(p,args)

for i=1:length(args)
    if isa(args{i},'org.xml.sax.ErrorHandler')
        p.setErrorHandler(args{i});
        break;
    end
end
