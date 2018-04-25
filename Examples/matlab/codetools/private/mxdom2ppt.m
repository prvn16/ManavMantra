function mxdom2ppt(dom,outputPath)
%MXDOM2PPT Create a PowerPoint presentation.

% Copyright 1984-2014 The MathWorks, Inc.

if ~ispc
   error(pm('PptPCOnly'))
end
try
   powerpApplication = actxserver('PowerPoint.Application');
catch %#ok<CTCH>
   error(pm('NoPpt'))
end

% Add new blank slide
openPresentation = powerpApplication.Presentations.Add;
presentationSlides = openPresentation.Slides;
slide = addSlide(openPresentation,presentationSlides);

% Get slide height and width
slideHeight = openPresentation.PageSetup.SlideHeight;
slideWidth = openPresentation.PageSetup.SlideWidth;

% Define constants.
margin = 18;
fullWidth = slideWidth - 2*margin;
imgWidth = 350;

% Get the overall document structure.
cellNodeList = dom.getElementsByTagName('cell');
[hasIntro,hasSections] = getStructure(cellNodeList);

% Create the presentation
for i = 1:cellNodeList.getLength
   cellNode = cellNodeList.item(i-1);

   % Pick out the main elements in this cell.
   titleNode = [];
   textNode = [];
   mcodeNode = [];
   mcodeoutputNode = [];
   hasOutputImages = false;
   cellChild = cellNode.getFirstChild;
   while ~isempty(cellChild)
      switch char(cellChild.getNodeName)
         case 'steptitle'
            titleNode = cellChild;
         case 'text'
            textNode = cellChild;
         case 'mcode'
            mcodeNode = cellChild;
         case 'mcodeoutput'
            mcodeoutputNode = cellChild;
         case 'img'
            hasOutputImages = true;
      end
      cellChild = cellChild.getNextSibling;
   end

   % Table of contents.
   if hasSections && ...
         (((i == 1) && ~hasIntro) || ((i == 2) && hasIntro))

      createToc(cellNodeList,slide,margin,fullWidth);
      % Leave this title on one slide alone
      slide = addSlide(openPresentation,presentationSlides);

   end

   % Add title
   if ~isempty(titleNode)
      % Extract node and title.
      title = char(titleNode.getFirstChild.getData);

      % Add a text box
      boxTitle = invoke(slide.Shapes,'AddTextbox',1,margin,90,fullWidth,36);
      textRange = boxTitle.TextFrame.TextRange;

      % Write the title
      set(textRange,'Text',title);

      % Set text alignment to center
      set(textRange.ParagraphFormat,'Alignment',2)

      % Make the text really big if it is the document title.
      switch char(titleNode.getAttribute('style'))
         case 'document'
            set(textRange.Font,'Size',66,'Bold',true);
         otherwise
            set(textRange.Font,'Size',32,'Bold',true);
      end

      % Leave this title on one slide alone
      slide = addSlide(openPresentation,presentationSlides);

   end
   
   % Add output images.  If stagger them, overlapping, down the page.  This
   % doesn't look great, but it makes it easier to rearrange them manually.
   childNode = cellNode.getFirstChild;
   imgCount = 0;
   while ~isempty(childNode)
      if isequal(char(childNode.getNodeName),'img')
          % Get the image path.
         img = char(childNode.getAttribute('src'));
         imgFile = resolvePath(outputPath,img);
         
         % Calculate the position.
         left = (slideWidth-imgWidth-margin) + 10*imgCount;
         top = margin + 10*imgCount;
         
         % Try to fetch the image size in pixels.
         try
             imgSize = size(imread(imgFile));
             vectorFormat = false;
         catch e
             if strcmp(e.identifier,'MATLAB:imagesci:imread:fileFormat')
                 vectorFormat = true;
             else
                 throw(e)
             end
         end
         
         % Handle vector and bitmap formats differently.
         if vectorFormat
             boxImage = slide.Shapes.AddPicture(imgFile,0,1,left,top);
         else
             imgHeight = imgWidth*(imgSize(1)/imgSize(2));
             boxImage = slide.Shapes.AddPicture(imgFile,0,1,left,top, ...
                 imgWidth,imgHeight);
         end
         
         imgCount = imgCount + 1;
         
      end
      childNode = childNode.getNextSibling;
   end

   % Add text
   if ~isempty(textNode)
      % If there are no images, use the whole width.
      if hasOutputImages
         width = fullWidth-margin-imgWidth;
      else
         width = fullWidth;
      end
      boxText = addTextNode(textNode,outputPath,slide,margin,margin,width);
      bottom = boxText.Top + boxText.Height;
   else
      bottom = margin;
   end

   % Add M-code.
   if ~isempty(mcodeNode)
      % Get the code.
      mcode = char(mcodeNode.getFirstChild.getData);
      mcode(mcode == char(10)) = char(13);

      % Calculate the position on the page.
      if hasOutputImages
         % Put it below the text AND below the image, if there is one.
         top = max(boxImage.Top+boxImage.Height,bottom);
      else
         % If there are no images, put the M-code right below the text.
         top = bottom;
      end

      % Add it to the slide.
      boxMcode = slide.Shapes.AddTextbox(1,margin,top,684,1);
      textRange = boxMcode.TextFrame.TextRange;
      textRange.Text = mcode;
      textRange.Font.Name = 'Lucida Console';
      updateSize(boxMcode)

      % If it doesn't fit on this page, move it to the next one.
      if ~slidesHeight(slideHeight,boxMcode.Height,boxMcode.Top+margin)
         boxMcode.Cut
         % Insert a new slide and write the M-code output
         slide = addSlide(openPresentation,presentationSlides);
         boxMcode = slide.Shapes.Paste;
         boxMcode.Item(1).Top = margin;
         boxMcode.Item(1).Left = margin;
      end

      bottom = boxMcode.Top + boxMcode.Height;
   end

   % Add M-code output
   if ~isempty(mcodeoutputNode)
      % Get the output.
      mcodeoutput = char(mcodeoutputNode.getFirstChild.getData);
      mcodeoutput(mcodeoutput == char(10)) = char(13);

      % Add it to the slide.
      boxMoutput = slide.Shapes.AddTextbox(1, ...
         margin,bottom,fullWidth,0);
      textRange = boxMoutput.TextFrame.TextRange;
      textRange.Text = mcodeoutput;
      textRange.Font.Name = 'Lucida Console';
      textRange.Font.Italic = true;
      updateSize(boxMoutput)

      % If it doesn't fit on this page, move it to the next one.
      if ~slidesHeight(slideHeight,boxMoutput.Height,boxMoutput.Top+margin)
         boxMoutput.Cut
         % Insert a new slide and write the M-code output
         slide = addSlide(openPresentation,presentationSlides);
         boxMoutput = slide.Shapes.Paste;
         boxMoutput.Item(1).Top = margin;
         boxMoutput.Item(1).Left = margin;
      end
   end

   % Add a new slide
   if (i < cellNodeList.getLength)
       slide = addSlide(openPresentation,presentationSlides);
   end
end

% Save the presentation.
openPresentation.SaveAs(outputPath);
openPresentation.Close;

% Close the application if no presentations remain.
if powerpApplication.presentations.Count == 0
    powerpApplication.Quit
    delete(powerpApplication)
end

%===============================================================================
function slide = addSlide(openPresentation,presentationSlides)

slidesCount = presentationSlides.Count + 1;
try
    % Works for older versions of Office.
    slide = presentationSlides.Add(slidesCount,'ppLayoutBlank');
catch %#ok<CTCH>
    % Works for Office 2007.
    ppLayoutBlank = 7;
    blankSlide = openPresentation.SlideMaster.CustomLayouts.Item(ppLayoutBlank);
    slide = presentationSlides.AddSlide(slidesCount,blankSlide);
end

%===============================================================================
function [s,yh] = slidesHeight(slideHeight,boxHeight,y)
%SLIDESHEIGHT   Validate slides Height

s = false;
yh = boxHeight + y;
if (yh < slideHeight)
   s = true;
end

%===============================================================================
function boxText = addTextNode(textNode,outputPath,slide,left,top,width)

% Add the text box
boxText = slide.Shapes.AddTextbox(1,left,top,width,0);
textRange = boxText.TextFrame.TextRange;

textChildNodeList = textNode.getChildNodes;
for j = 1:textChildNodeList.getLength
   textChildNode = textChildNodeList.item(j-1);
   switch char(textChildNode.getNodeName)
      case 'p'
         if isequal(char(textChildNode.getFirstChild.getNodeName),'img')
            src = char(textChildNode.getFirstChild.getAttribute('src'));
            boxText = addImg(src,outputPath,slide,boxText);
            textRange = boxText.TextFrame.TextRange;
            textRange = textRange.InsertAfter(' ');
            textRange = textRange.InsertAfter(char(10));
         elseif isequal(char(textChildNode.getFirstChild.getNodeName),'equation')
            src = char(textChildNode.getFirstChild.getFirstChild.getAttribute('src'));
            boxText = addEquation(src,outputPath,slide,boxText);
            textRange = boxText.TextFrame.TextRange;
            textRange = textRange.InsertAfter(' ');
            textRange = textRange.InsertAfter(char(10));
         else
            textRange = addText(textChildNode,textRange,'p');
            textRange = newLine(textRange);
         end
         textRange = newLine(textRange);

      case {'ul','ol'}
         pChildNodeList = textChildNode.getChildNodes;
         for k = 1:pChildNodeList.getLength
            liNode = pChildNodeList.item(k-1);
            textRange = addText(liNode,textRange,'p');
            textRange = newLine(textRange);
            switch char(textChildNode.getNodeName)
                case 'ul'
                    textRange.ParagraphFormat.Bullet.Type = 'ppBulletUnnumbered';
                case 'ol'
                    textRange.ParagraphFormat.Bullet.Type = 'ppBulletNumbered';
            end
         end
         textRange = newLine(textRange);
         textRange.ParagraphFormat.Bullet.Type = 'ppBulletNone';
      case 'pre'
         textRange = addText(textChildNode,textRange,'pre');
         textRange = newLine(textRange);
         textRange = newLine(textRange);
      otherwise
         dpm('NotImplemented',char(textChildNode.getNodeName))
   end
   updateSize(boxText)
end

%===============================================================================
function textRange = addText(textChildNode,textRange,type)
switch type
   case 'p'
      defaultFont = 'Arial';
   case 'pre'
      defaultFont = 'Lucida Console';
end
pChildNodeList = textChildNode.getChildNodes;
for k = 1:pChildNodeList.getLength
   pChildNode = pChildNodeList.item(k-1);
   if isempty(pChildNode.getFirstChild)
      nextText = char(pChildNode.getData);
   elseif strcmp(char(pChildNode.getFirstChild.getNodeName),'img')
      nextText = char(pChildNode.getFirstChild.getAttribute('alt'));
   else
       nextText = char(pChildNode.getTextContent);
   end
   nextText(nextText == char(10)) = char(13);
   switch char(pChildNode.getNodeName)
      case {'#text','equation'}
         textRange = textRange.InsertAfter(nextText);
         textRange.Font.Name = defaultFont;
         textRange.Font.Bold = false;
         textRange.Font.Italic = false;
      case 'a'
         textRange = textRange.InsertAfter(nextText);
         aHref = char(pChildNode.getAttribute('href'));
         a = textRange.ActionSettings(1);
         a.Item(1).Action = 'ppActionHyperLink';
         a.Item(1).Hyperlink.Address = aHref;
         textRange.Font.Name = defaultFont;
         textRange.Font.Bold = false;
         textRange.Font.Italic = false;
      case 'b'
         textRange = textRange.InsertAfter(nextText);
         textRange.Font.Name = defaultFont;
         textRange.Font.Bold = true;
         textRange.Font.Italic = false;
      case 'i'
         textRange = textRange.InsertAfter(nextText);
         textRange.Font.Name = defaultFont;
         textRange.Font.Bold = false;
         textRange.Font.Italic = true;
      case 'tt'
         textRange = textRange.InsertAfter(nextText);
         textRange.Font.Name = 'Lucida Console';
         textRange.Font.Bold = false;
         textRange.Font.Italic = false;
      case {'html','latex'}
         % Drop these on the floor.
      otherwise
         dpm('NotImplemented',char(pChildNode.getNodeName));
   end
end


%===============================================================================
function textRange = newLine(textRange)
% Even though we don't need nulls, if we don't ask for them PowerPoint
% won't let us close it.  Strange.
textRange = textRange.InsertAfter(char(13));

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
function boxText = addImg(src,outputPath,slide,boxText)

top = boxText.Top + boxText.Height;
left = boxText.Left;
width = boxText.Width;

[toInclude,toDelete] = resolvePath(outputPath,src);
shape = slide.Shapes.AddPicture(toInclude,0,1,left,top,1,1);
shape.ScaleWidth(1,1);
shape.ScaleHeight(1,1);
delete(toDelete)

boxText = slide.Shapes.AddTextbox(1,left,shape.Top+shape.Height,width,0);

%===============================================================================
function boxText = addEquation(src,outputPath,slide,boxText)

top = boxText.Top + boxText.Height;
left = boxText.Left;
width = boxText.Width;

shape = slide.Shapes.AddPicture(resolvePath(outputPath,src),0,1,left,top,1,1);
shape.ScaleWidth(1,1);
shape.ScaleHeight(1,1);

boxText = slide.Shapes.AddTextbox(1,left,shape.Top+shape.Height,width,0);

%===============================================================================
function createToc(cellNodeList,slide,margin,fullWidth)
boxToc = slide.Shapes.AddTextbox(1,margin,margin,fullWidth,10);
textRange = boxToc.TextFrame.TextRange;

textRange.Text = ['Overview' char(13) char(13)];

for j = 1:cellNodeList.getLength
   cellNode = cellNodeList.item(j-1);
   
   % Document titles shouldn't be in the TOC.
   style = char(cellNode.getAttribute('style'));
   if strcmp(style,'overview')
       continue
   end
   
   child = cellNode.getFirstChild;
   while ~isempty(child)
      if isequal('steptitle',char(child.getNodeName))
         title = char(child.getFirstChild.getData);
         textRange = textRange.InsertAfter(char(10));
         textRange.ParagraphFormat.Bullet.Type = 'ppBulletUnnumbered';
         textRange.Text = title;
         textRange = newLine(textRange);
      end
      child = child.getNextSibling;
   end
end

textRange = boxToc.TextFrame.TextRange;
textRange.Font.Size = 32;
textRange.Font.Bold = true;


%===============================================================================
function updateSize(boxText)
% We shouldn't need this function, but the Textbox don't seem to respect their
% autoshape property.
boxText.Height = boxText.TextFrame.TextRange.BoundHeight;
boxText.TextFrame.AutoSize = 'ppAutoSizeShapeToFitText';

%===============================================================================
function m = pm(id,varargin)
m = message(['MATLAB:publish:' id],varargin{:});

%===============================================================================
function s = spm(id,varargin)
s = getString(pm(id,varargin{:}));

%===============================================================================
function dpm(id,varargin)
disp(spm(id,varargin{:}));
