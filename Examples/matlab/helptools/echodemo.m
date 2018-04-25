function echodemo(inputFilename,cellIndex)
%ECHODEMO Run a cell script as an echo-and-pause command line demo.
%   ECHODEMO FILENAME displays a cell script FILENAME.  Cell scripts can be
%   created using Cell Mode in the MATLAB Editor. The demo is advanced by
%   clicking on HTML hypertext links embedded in the command window.
%
%   ECHODEMO('FILENAME',CELLINDEX) evaluates the cell number given by
%   CELLINDEX.

% Copyright 2002-2015 The MathWorks, Inc.

% Keep a persistent store of two things: the parsed cell code, and the name
% of the file. The filename is stored as a precaution against jumping into
% the middle of a new demo
persistent cellStruct cellFilename lastCell lastCellFinished

% lineWidth is the expected width of the display area in the command window
lineWidth = 75;

% Argument parsing.
if nargin < 2
    cellIndex = 1;
end

% If we're in -nodesktop mode, fall back on pause-style.
if (cellIndex == 1) && ~usejava('desktop')
    playshow(inputFilename,'echo')
    return
end

% Locate the MATLAB file.
if isempty(regexp(inputFilename,'\.m$','once'))
    % Tack a ".m" on the end to avoid picking up a P-file.
    inputFilename = strcat(inputFilename, '.m');
end
inputFilename = char(inputFilename);
fullpath = which(inputFilename);

if strcmp(fullpath,cellFilename) && ~isempty(lastCell) && ...
        (cellIndex == lastCell) && (now-lastCellFinished < 1/24/60/60/10)
    % Prevent repeated pressing of "Next" to pile up.
    return
elseif strcmp(fullpath,cellFilename) && (cellIndex ~= 1)
    % Use cached version.
else
    % Read in the file.
    fid = fopen(fullpath);
    if (fid == -1)
        error(message('MATLAB:echodemo:FileNotFound',inputFilename));
    end
    txt = native2unicode(fread(fid,'uint8=>uint8')');
    fclose(fid);
    
    % Parse the char data into a structure.
    cellStruct = m2struct(txt);
    cellFilename = fullpath;
end

[basedir,fcnname] = fileparts(fullpath);
% Bring the command window to the front
commandwindow

% Clear the command window display area
home

% Build left side of the header.
if cellIndex < length(cellStruct)
    leftHeader = sprintf('Click <a href="matlab:echodemo(''%s'',%d)">Next</a> to continue or <a href="matlab:home">Stop</a> to end', ...
        fcnname, ...
        cellIndex+1);
elseif cellIndex == length(cellStruct)
    leftHeader = sprintf('End of demo. Click <a href="matlab:echodemo(''%s'',1)">Replay</a> to see it again', ...
        fcnname);
elseif cellIndex > length(cellStruct)
    error(message('MATLAB:echodemo:TooHigh',length(cellStruct),fcnname))
end

% Build right side of the header.
rtHeader = sprintf('     <a href="matlab:edit(''%s'')">%s.m</a> (%d/%d)', ...
    fcnname, ...
    fcnname, ...
    cellIndex, ...
    length(cellStruct));

% In order to get the spacing right, we need to figure out the length of
% these headers minus the text hidden in the HTML anchor tags
leftHeaderLen = length(regexprep(leftHeader,'<.*?>',''));
rtHeaderLen = length(regexprep(rtHeader,'<.*?>',''));
spacer = char(32*ones(1,lineWidth - leftHeaderLen - rtHeaderLen));
fprintf('%s%s%s\n',leftHeader,spacer,rtHeader);

% Display the top separator.
fprintf('%s\n',char(abs('-')*ones(1,lineWidth)));

% Pull out the data for this cell.
thisCell = cellStruct(cellIndex);

% Display the title.
if ~isempty(thisCell.title)
    fprintf(' %s\n',upper(thisCell.title)); 
end

% Trim newlines off the end of the text.
while ~isempty(thisCell.text) && isempty(thisCell.text{end})
    thisCell.text(end) = [];
end

% Leave a blank line between the title and the text.
if ~isempty(thisCell.title) && ~isempty(thisCell.text)
    fprintf('\n');
end

% Display the text.
linkPattern = '\<(<\S.*?\S>)\>';
fromLastLine = '';
for n = 1:length(thisCell.text)
    toNextLine = '';
    line = [fromLastLine char(thisCell.text{n})];
    image = regexp(line,'^<<(.*)>>$','tokens');
    if ~isempty(image)
        % Image link.
        line = (['<a href="file:///' basedir '/html/' image{1}{1} '">' image{1}{1} '</a>']);
    else
        % Check for other links.
        [~,~,linkTokens] = regexp(line,linkPattern);
        if n ~= length(thisCell.text)
            % Check to see if a link is split along two lines.
            nextLine = char(thisCell.text{n+1});
            nextTokens = regexp(nextLine,linkPattern,'tokenExtents');
            twoLines = [line ' ' nextLine];
            twoTokens = regexp(twoLines,linkPattern,'tokenExtents');
            if length(twoTokens) > (length(linkTokens) + length(nextTokens))
                % Move this part to the next line.
                breakLineAt = twoTokens{length(linkTokens)+1}(1);
                toNextLine = [line(breakLineAt:end) ' '];
                line = line(1:breakLineAt-1);
            end
        end
        
        % Convert each link to HTML.
        for iTokens = length(linkTokens):-1:1
            linkStart = linkTokens{iTokens}(1);
            linkEnd = linkTokens{iTokens}(2);
            link = line(linkStart+1:linkEnd-1);
            spacePosition = find(link == ' ',1,'first');
            if isempty(spacePosition)
                % Use the link as the link text.
                linkUrl = link;
                linkText = link;
            else
                % Use alternate text for the link text.
                linkUrl = link(1:spacePosition-1);
                linkText = link(spacePosition+1:end);
            end
            % Check for relative URL.
            noColons = ~contains(linkUrl,':');
            if noColons
                if linkUrl(1) == '#'
                    linkUrl = ['file:///' basedir '/html/' fcnname '.html' linkUrl]; %#ok<AGROW>
                else
                    linkUrl = ['file:///' basedir '/html/' linkUrl]; %#ok<AGROW>
                end
            end
            line = [line(1:linkStart-1) '<a href="' linkUrl '">' linkText '</a>' line(linkEnd+1:end)];
        end
    end
    fprintf(' %s\n',line);
    fromLastLine = toNextLine;
end

% Display the bottom separator.
fprintf('%s\n\n',char(abs('-')*ones(1,lineWidth)));

% Display and evaluate the code.
if ~isempty(thisCell.code)
    fprintf('%s\n\n',thisCell.code);
    figureState = internal.matlab.publish.captureFigures;
    try
        mcodeoutput = evalc('evalin(''base'',thisCell.code)');
    catch mExc
        mcodeoutput = '';
        disp(formatError(mExc))
        beep
        cellFilename = '';
    end
    changedFigures = internal.matlab.publish.compareFigures(figureState);
    if ~isempty(mcodeoutput)
        fprintf('%s\n',mcodeoutput);
    end
    for i = 1:length(changedFigures)
        figure(changedFigures(i))
    end
end

lastCell = cellIndex;
lastCellFinished = now;

function m = formatError(laste)
m = getReport(laste);

% Trim out the ECHODEMO stack from the error.
iRet = find(m==sprintf('\n'));
instrumentAndRunPos = strfind(m,'echodemo');
stackStart = max(iRet(iRet < instrumentAndRunPos(end)));
causePos = strfind(m,getCauseString);
if isempty(causePos)
    stackEnd = numel(m);
else
    stackEnd = max(iRet(iRet < causePos(end)))-1;
end
m(stackStart:stackEnd) = [];

% Trim trailing newline.
if ~isempty(causePos)
    m(end) = [];
end

function s = getCauseString
M1 = MException('foo:bar','');
M2 = MException('foo2:bar2','');
M2 = M2.addCause(M1);
s = strtrim(getReport(M2));

