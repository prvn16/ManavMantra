function demowin(callback,product,label,body,base,keywords)
%DEMOWIN Display demo information in the Help window
%
%   This file is a helper function used by the Help Browser's Demo tab.  It is
%   unsupported and may change at any time without notice.

%   Copyright 1984-2015 The MathWorks, Inc.

if (nargin < 6)
    keywords = {};
elseif isstring(keywords)
    keywords = cellstr(keywords);
end
if (nargin < 5)
    base = '';
else
    base = char(base);
end
if nargin > 3 && isstring(body)
    body = char(body);
end
if nargin > 2 && isstring(label)
    label = char(label);
end
if nargin > 1 && isstring(product)
    product = char(product);
end
if nargin > 0 && isstring(callback)
    callback = char(callback);
end

% Determine the function name.

% Start by assuming the callback is a function name and trim it down.
fcnName = char(com.mathworks.mde.help.DemoPageBuilder.getDemoFuncNameFromCallback(callback));

% Find where this function lives.
itemLoc = which(fcnName);
if ~isempty(itemLoc)
   [~,fcnName] = fileparts(itemLoc);
else
   fcnName = '';
end

%%%% Build the main body of the page.

if ~isempty(body)
   % We've already got one.  Just use it.
   % Assume it has its own H1.
   label = '';
else
   helpStr = help(fcnName);
   if isempty(fcnName) || isempty(helpStr)
      body = '<p></p>';
   else
      % Build the HTML from the help.
      body = [markupHelpStr(helpStr,fcnName) newline];
   end
end

%%%% Determine the header navigation.

if isempty(callback)
   leftText = '';
   leftAction = '';
   rightText = '';
   rightAction = '';
elseif exist([fcnName '.mdl'],'file')
   leftText = [fcnName '.mdl'];
   leftAction = '';
   rightText = ms('OpenThisModel');
   rightAction = callback;
elseif exist([fcnName '.slx'],'file')
   leftText = [fcnName '.slx'];
   leftAction = '';
   rightText = ms('OpenThisModel');
   rightAction = callback;
else
   leftText = ms('OpenInEditor',fcnName);
   leftAction = ['edit ' fcnName];
   rightText = ms('RunThisDemo');
   rightAction = callback;
end

%%%% Determine the header "h1" label.

if isempty(label)
   H1 = '';
else
   H1 = ['<h1>' label '</h1>'];
end

%%%% Assemble the page.
demoStr = ms('Demo');
if ~isempty(fcnName)
    title = sprintf('%s %s: %s', product, demoStr, fcnName);
else
    title = sprintf('%s %s', product);
end

htmlBegin = ['<html>' newline ...
      '<head>' newline ...
      '<title>' title '</title>' newline ...
      '<base href="' base '">' newline ...
      '<link rel="stylesheet" type="text/css" ' newline ...
      '  href="file:///' matlabroot '/toolbox/matlab/helptools/private/style.css">' newline ...
      '</head>' newline ...
      '<body>'];

header = makeHeader(leftText,leftAction,rightText,rightAction);
htmlEnd = sprintf('\n</body>\n</html>\n');

outStr = [htmlBegin header newline '<div class="content">' newline ...
    H1 newline body newline '</div>' newline htmlEnd];

if (isempty(keywords))
    com.mathworks.mlservices.MLHelpServices.setDemoText(outStr);
else
    com.mathworks.mlservices.MLHelpServices.setHtmlTextAndHighlightKeywords(outStr, keywords);
end

%===============================================================================
function h = makeHeader(leftText,leftAction,rightText,rightAction)

% Left chunk.
leftData = leftText;
if ~isempty(leftAction)
   leftData = ['<a href="matlab:' leftAction '">' leftData '</a>'];
end

% Right chunk.
rightData = rightText;
if ~isempty(rightAction)
   rightData = ['<a href="matlab:' rightAction '">' rightData '</a>'];
end

h = ['<div class="header">' ...
    '<div class="left">' leftData '</div>' ...
    '<div class="right">' rightData '</div>' ...
    '</div>'];

%===============================================================================
function helpStr = markupHelpStr(helpStr,fcnName)

nameChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_/';
delimChars = [ '., ' newline ];

% Handle characters that are special to HTML
helpStr = strrep(helpStr, '&', '&amp;');
helpStr = strrep(helpStr, '<', '&lt;');
helpStr = strrep(helpStr, '>', '&gt;');

% Make "see also" references act as hot links.
seeAlso = ms('SeeAlso');
lengthSeeAlso = length(seeAlso);
xrefStart = strfind(helpStr,seeAlso);
if ~isempty(xrefStart)
   % Determine start and end of "see also" potion of the help output
   pieceStr = helpStr(xrefStart(1)+lengthSeeAlso : length(helpStr));
   periodPos = strfind(pieceStr, '.');
   overloadPos = strfind(pieceStr, 'Overloaded functions or methods');
   if ~isempty(periodPos)
      xrefEnd = xrefStart(1)+lengthSeeAlso + periodPos(1);
      trailerStr = pieceStr(periodPos(1)+1:length(pieceStr));
   elseif ~isempty(overloadPos)
      xrefEnd = xrefStart(1)+lengthSeeAlso + overloadPos(1);
      trailerStr = pieceStr(overloadPos(1):length(pieceStr));
   else
      xrefEnd = length(helpStr);
      trailerStr = '';
   end

   % Parse the "See Also" portion of help output to isolate function names.
   seealsoStr = '';
   word = '';
   for chx = xrefStart(1)+lengthSeeAlso : xrefEnd
      if length(strfind(nameChars, helpStr(chx))) == 1
         word = [ word helpStr(chx)];
      elseif (length(strfind(delimChars, helpStr(chx))) == 1)
         if ~isempty(word)
            % This word appears to be a function name.
            % Make link in corresponding "see also" string.
            fname = lower(word);
            seealsoStr = [seealsoStr '<a href="matlab:doc ' fname '">' fname '</a>'];
         end
         seealsoStr = [seealsoStr helpStr(chx)];
         word = '';
      else
         seealsoStr = [seealsoStr word helpStr(chx)];
         word = '';
      end
   end
   % Replace "See Also" section with modified string (with links)
   helpStr = [helpStr(1:xrefStart(1)+lengthSeeAlso -1) seealsoStr trailerStr];
end

% If there is a list of overloaded methods, make these act as links.
overloadPos =  strfind(helpStr, 'Overloaded functions or methods');
if ~isempty(overloadPos)
   pieceStr = helpStr(overloadPos(1) : length(helpStr));
   % Parse the "Overload methods" section to isolate strings of the form "help DIRNAME/METHOD"
   overloadStr = '';
   linebrkPos = find(pieceStr == newline);
   lineStrt = 1;
   for lx = 1 : length(linebrkPos)
      lineEnd = linebrkPos(lx);
      curLine = pieceStr(lineStrt : lineEnd);
      methodStartPos = strfind(curLine, ' help ');
      methodEndPos = strfind(curLine, '.m');
      if (~isempty(methodStartPos) ) && (~isempty(methodEndPos) )
         linkTag = ['<a href="matlab:doc ' curLine(methodStartPos(1)+6:methodEndPos(1)+1) '">'];
         overloadStr = [overloadStr curLine(1:methodStartPos(1)) linkTag curLine(methodStartPos(1)+1:methodEndPos(1)+1) '</a>' curLine(methodEndPos(1)+2:length(curLine))];
      else
         overloadStr = [overloadStr curLine];
      end
      lineStrt = lineEnd + 1;
   end
   % Replace "Overloaded methods" section with modified string (with links)
   helpStr = [helpStr(1:overloadPos(1)-1) overloadStr];
end

% Highlight occurrences of the function name
helpStr = strrep(helpStr,[' ' upper(fcnName) '('],[' <b>' lower(fcnName) '</b>(']);
helpStr = strrep(helpStr,[' ' upper(fcnName) ' '],[' <b>' lower(fcnName) '</b> ']);

helpStr = ['<pre><code>' helpStr '</code></pre>'];

%==========================================================================
function s = ms(id,varargin)
s = getString(message(['MATLAB:demowin:' id],varargin{:}));