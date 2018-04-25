function mxdom2word(dom,outputPath)
%MXDOM2WORD Write the DOM out to a Word document.
%   MXDOM2WORD(dom,outputPath)

% Matthew J. Simoneau
% Copyright 1984-2017 The MathWorks, Inc.

if ~ispc
    error(pm('WordPCOnly'))
end
try
    wordApplication = actxserver('Word.Application');
catch
    error(pm('NoWord'))
end

% Define constants.
wdStyleNormal = -1;
wdStyleHeading1 = -2;
wdStyleHeading2 = -3;
wdFormatDocument = 0;

%set(wordApplication,'Visible',1); % Great for debugging.
documents = wordApplication.Documents;

% Create a new document.  We used to just do
%
%   doc = documents.Add;
%
% To work around issues with the add do this less satifying two-line version:
documents.Add;
doc = documents.Item(documents.Count);

addCodeStyleUnlessAlreadyDefined(wordApplication)
addOutputStyleUnlessAlreadyDefined(wordApplication)

activeDocument = wordApplication.ActiveDocument;
selection = wordApplication.Selection;
cellNodeList = dom.getElementsByTagName('cell');
[hasIntro,hasSections] = getStructure(cellNodeList);
for i = 1:cellNodeList.getLength
    cellNode = cellNodeList.item(i-1);

    % Table of contents.
    if hasSections && ...
            (((i == 1) && ~hasIntro) || ((i == 2) && hasIntro))
        toc = activeDocument.TablesOfContents.Add(selection.Range);
        set(toc,'UpperHeadingLevel',2)
        set(toc,'LowerHeadingLevel',2)
        selection.EndKey;
        selection.MoveDown;
    end

    % Add title.
    titleNodeList = cellNode.getElementsByTagName('steptitle');
    if (titleNodeList.getLength > 0)
        titleNode = titleNodeList.item(0);
        switch char(titleNode.getAttribute('style'))
            case 'document'
                set(selection,'Style',wdStyleHeading1)
            otherwise
                set(selection,'Style',wdStyleHeading2)
        end
        addText(titleNode,selection,wordApplication,outputPath)
        selection.TypeParagraph;
        set(selection,'Style',wdStyleNormal)
    end

    % Add text.
    textNodeList = cellNode.getElementsByTagName('text');
    if (textNodeList.getLength == 1)
        textNode = textNodeList.item(0);
        addTextNode(textNode,selection,wordApplication,outputPath);
    end

    % Add code.
    childNode = cellNode.getFirstChild;
    while ~isempty(childNode)
        if strcmp(char(childNode.getNodeName),'mcode-xmlized')
            set(selection,'Style','MATLAB Code')
            addText(childNode,selection,wordApplication,outputPath)
            selection.TypeParagraph;
            set(selection,'Style',wdStyleNormal)
            break
        end
        childNode = childNode.getNextSibling;
    end
    
    % Add output text and images.
    childNode = cellNode.getFirstChild;
    while ~isempty(childNode)
        switch char(childNode.getNodeName)
            case 'mcodeoutput'
                addMcodeoutput(selection,childNode,wdStyleNormal)
            case 'img'
                addOutputImaget(selection,childNode,outputPath)
        end
        childNode = childNode.getNextSibling;
    end
    
end

% Footer.
addFooter(dom,selection,activeDocument)

% Refresh the Table of Contents
if hasSections
    toc.Update;
end

% Return to the top of the document.
%invoke(selection,'GoTo',0);

try
    try
        % This will work on Word 2010.
        doc.SaveAs2(outputPath,wdFormatDocument);
    catch %#ok<CTCH>
        doc.SaveAs(outputPath,wdFormatDocument);
    end
catch anError
    if ~isempty(strfind(anError.message,'already open elsewhere'))
        errordlg(spm('WordAlreadyOpen',outputPath),spm('PublishingError'));
        error(pm('WordAlreadyOpen',outputPath));
    else
        rethrow(anError);
    end
end
doc.Close(0);
wordApplication.Quit

%===============================================================================
function addCodeStyleUnlessAlreadyDefined(wordApplication)

try
    codeStyle = wordApplication.ActiveDocument.Styles.Add('MATLAB Code');
catch
    % This errors if the user already has a style "MATLAB Code" defined.
    % If so, just use that style.
    return
end

set(codeStyle.Font,'Name','Lucida Console','Size',8)

try
    set(codeStyle.ParagraphFormat.Borders,'Enable',1, ...
        'OutsideLineWidth','wdLineWidth025pt','OutsideColor','wdColorGray20', ...
        'DistanceFromBottom',10,'DistanceFromLeft',10, ...
        'DistanceFromRight',10,'DistanceFromTop',10);
    set(codeStyle.ParagraphFormat,'LineSpacing',18);
    set(codeStyle.ParagraphFormat.Shading,'BackgroundPatternColor','wdColorGray05');
end

try
    % This will error for Word 97.
    set(codeStyle,'NoProofing',true);
end

%===============================================================================
function addOutputStyleUnlessAlreadyDefined(wordApplication)

% Create MATLAB Output style.
try
    outputStyle = wordApplication.ActiveDocument.Styles.Add('MATLAB Output');
catch e
    % This errors if the user already has a style "MATLAB Output" defined.
    % If so, just use that style.
    return
end

% Set font and size.
set(outputStyle.Font,'Name','Lucida Console','Size',8)

% Set color to gray.
try
    set(outputStyle.Font,'Color','wdColorGray80')
catch e
    if strcmp(e.identifier,'MATLAB:class:AmbiguousPropertyException')
        % This is the error on 2010. Try one more.
        try
            set(outputStyle.Font,'ColorIndex','wdGray50')
        catch
            % Never mind.
        end
    end
end

try
    set(outputStyle.ParagraphFormat,'LineSpacing',18);
end

% This will error for Word 97.
try
    set(outputStyle,'NoProofing',true);
end

%===============================================================================
function addMcodeoutput(selection,childNode,wdStyleNormal)
% Add output.
mcodeoutput = char(childNode.getFirstChild.getData);
mcodeoutput(mcodeoutput==10) = 11;
if mcodeoutput(end) == 11
    % The only time this won't be true is when someone used fprintf or
    % similar and the prompt wouldn't be on its own line.
    mcodeoutput(end) = [];
end
set(selection,'Style','MATLAB Output')
n = numel(mcodeoutput);
frame = 10000;
for i = 1:(n/frame)+1
    firstPosition = (i-1)*frame+1;
    lastPosition = min(i*frame,n);
    selection.TypeText(mcodeoutput(firstPosition:lastPosition))
end
selection.TypeParagraph;
set(selection,'Style',wdStyleNormal)

%===============================================================================
function addOutputImaget(selection,childNode,outputPath)
img = char(childNode.getAttribute('src'));
imgFile = resolvePath(outputPath,img);
selection.InlineShapes.AddPicture(imgFile);
selection.TypeParagraph;

%===============================================================================
function addTextNode(textNode,selection,wordApplication,outputPath)
textChildNodeList = textNode.getChildNodes;
for j = 1:textChildNodeList.getLength
    textChildNode = textChildNodeList.item(j-1);
    switch char(textChildNode.getNodeName)
        case 'p'
            addText(textChildNode,selection,wordApplication,outputPath)
            selection.TypeParagraph;
        case {'ul','ol'}
            pChildNodeList = textChildNode.getChildNodes;
            switch char(textChildNode.getNodeName)
                case 'ul'
                    selection.Range.ListFormat.ApplyBulletDefault
                case 'ol'
                    selection.Range.ListFormat.ApplyNumberDefault
            end
            for k = 1:pChildNodeList.getLength
                liNode = pChildNodeList.item(k-1);
                addText(liNode,selection,wordApplication,outputPath)
                selection.TypeParagraph;
            end
            selection.Range.ListFormat.RemoveNumbers;
        case {'pre','mcode-xmlized'}
            font = selection.Font;
            ttProps = {'Name','Size'};
            ttVals = {'Lucida Console',10};
            orig = get(font,ttProps);
            set(font,ttProps,ttVals)
            addText(textChildNode,selection,wordApplication,outputPath)
            set(font,ttProps,orig)
            selection.TypeParagraph;
        otherwise
            dpm('NotImplemented',char(textChildNode.getNodeName))
    end
end

%===============================================================================
function addText(textChildNode,selection,wordApplication,outputPath)
activeDocument = wordApplication.ActiveDocument;
pChildNodeList = textChildNode.getChildNodes;
for k = 1:pChildNodeList.getLength
    pChildNode = pChildNodeList.item(k-1);
    switch char(pChildNode.getNodeName)
        case '#text'
            s = char(pChildNode.getData);
            s(s == 10) = 11;
            selection.TypeText(s)

        case 'mwsh:code'
            addText(pChildNode,selection,wordApplication,outputPath)
            
        case 'img'
            src = char(pChildNode.getAttribute('src'));
            [toInclude,toDelete] = resolvePath(outputPath,src);
            selection.InlineShapes.AddPicture(toInclude);
            delete(toDelete)

        case 'equation'
            equationImage = char(pChildNode.getFirstChild.getAttribute('src'));
            equationImageFile = resolvePath(outputPath,equationImage);
            inlineShape = selection.InlineShapes.AddPicture(equationImageFile);
            equationText = char(pChildNode.getAttribute('text'));            
            inlineShape.AlternativeText = equationText;

        case {'html','latex'}
            % Don't show these in this format.

        otherwise
            % Add text recursively and define a range.
            start = selection.Range.Start;
            addText(pChildNode,selection,wordApplication,outputPath)
            range = activeDocument.Range(start,selection.Range.Start);
            
            % Range operations can clear the selection's values.  Save them.
            % ColorIndex can't be handled this way in Office 2007 and is
            % handled separately.
            selectionProps = {'Bold','Italic','Name','Size'};
            selectionValues = get(selection.Font,selectionProps);
            
            % Apply the formatting to the range.
            switch char(pChildNode.getNodeName)
                case 'a'
                    aHref = char(pChildNode.getAttribute('href'));
                    hyperLinks = activeDocument.Hyperlinks;
                    hyperLinks.Add(range,aHref,'',aHref);
                case 'b'
                    range.Font.Bold = true;
                case 'i'
                    range.Font.Italic = true;
                case 'tt'
                    range.Font.Name = 'Lucida Console';
                    range.Font.Size = 10;
                case 'mwsh:keywords'
                    range.Font.ColorIndex = 'wdBlue';
                    selection.Font.ColorIndex = 'wdBlack';
                case 'mwsh:strings'
                    range.Font.ColorIndex = 'wdDarkRed';
                    selection.Font.ColorIndex = 'wdBlack';
                case 'mwsh:comments'
                    range.Font.ColorIndex = 'wdGreen';
                    selection.Font.ColorIndex = 'wdBlack';
                case 'mwsh:unterminated_strings'
                    range.Font.ColorIndex = 'wdRed';
                    selection.Font.ColorIndex = 'wdBlack';
                case 'mwsh:system_commands'
                    range.Font.ColorIndex = 'wdDarkYellow';
                    selection.Font.ColorIndex = 'wdBlack';
                otherwise
                    dpm('NotImplemented',char(pChildNode.getNodeName));
            end
            
            % Range operations can clear the selection's values.  Restore them.
            set(selection.Font,selectionProps,selectionValues);
       
    end
end

%===============================================================================
function [hasIntro,hasSections] = getStructure(cellNodeList)

hasIntro = false;
if (cellNodeList.getLength > 0)
    style = char(cellNodeList.item(0).getAttribute('style'));
    if isequal(style,'overview')
        hasIntro = true;
    end
end

hasSections = false;
for i = 1:cellNodeList.getLength
    cellNode = cellNodeList.item(i-1);
    titleNodeList = cellNode.getElementsByTagName('steptitle');
    if (titleNodeList.getLength > 0)
        titleNode = titleNodeList.item(0);
        style = char(titleNode.getAttribute('style'));
        if ~isequal(style,'document')
            hasSections = true;
            break
        end
    end
end

%===============================================================================
function addFooter(dom,selection,activeDocument)


% Style footer.
selection.Font.Italic = true;
selection.NoProofing = true;
selection.Font.ColorIndex = 'wdGray50';

% Add copyright, if applicable.
copyrightList = dom.getElementsByTagName('copyright');
if (copyrightList.getLength > 0)
    copyright = char(copyrightList.item(0).getFirstChild.getData);
    selection.TypeText(copyright)
    selection.TypeText(char(11));
end

% Build message.
release = char(dom.getElementsByTagName('release').item(0).getTextContent());
rMessage = ['Published with MATLAB' char(174) ' R' release];

% Add message.
start = selection.Range.Start;
selection.TypeText(rMessage)
linkRange = activeDocument.Range(start,selection.Range.Start);

% Link message.
pHref = 'https://www.mathworks.com/products/matlab';
hyperLinks = activeDocument.Hyperlinks;
hyperLinks.Add(linkRange,pHref,'',pHref);
linkRange.Font.Underline = false;

%===============================================================================
function m = pm(id,varargin)
m = message(['MATLAB:publish:' id],varargin{:});

%===============================================================================
function s = spm(id,varargin)
s = getString(pm(id,varargin{:}));

%===============================================================================
function dpm(id,varargin)
disp(spm(id,varargin{:}));
