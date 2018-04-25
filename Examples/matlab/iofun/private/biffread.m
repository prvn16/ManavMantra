function biffvector = biffread(filename)
%BIFFREAD read biff vector from xls file

%   Copyright 1984-2007 The MathWorks, Inc.

% read the biff file using fread or error
%
% if the first byte is 9, this is an old style (pre excel 95) file
%     
% if byte 513 is 9, this is a Storage file with a short header
% 
% if byte 2049 is 9, this is a Storage file with a long header
% 
% if none of these are true, scan for [9 x] pairs in the biff
% vector and start reading from there.  x is the biff version
   
fid = fopen(filename,'r','l'); % always use little endian for read
if fid < 0
    error(message('MATLAB:xlsread:biffread:FileNotFound', filename));
end
biffvector = fread(fid, inf, '*uint8');
fclose(fid);
if isempty(biffvector)
    error(message('MATLAB:xlsread:biffread:FileEmpty', filename));
end

if biffvector(1) == 9
    % this is a pre excel95 biff file, use it as is
elseif length(biffvector) > 512 && biffvector(513) == 9 
    % this is a structured storage file with a 512 byte header.
    % the 1st record is a biff record throw away the 1st 512 bytes
    biffvector = biffvector(513:end);
elseif length(biffvector) > 2048 && biffvector(2049) == 9 
    % this is a structured storage file with a 2048 byte header or something other
    % than biff in the 1st record, throw away the 1st 2048 bytes
    biffvector = biffvector(2049:end);
else
    % look through the whole file for data of the form [9 x] where x is the
    % biff version. try biff versions 8 through 12 - if the biff version gets
    % much more than 12, we'll likely need to rewrite biffparse.
    start = [];
    for biffver = 8:12
        start = findHeader(biffvector, biffver);
        if ~isempty(start)
            biffvector = biffvector(start:end);
            break;
        end
    end
    if isempty(start)
        error(message('MATLAB:xlsread:biffread:FileFormat', filename));
    end
end

biffvector = exciseE2007Junk(biffvector');


function start = findHeader(in, biffver)
% look for the 1st occurrence of a 9 followed by the biff version - this is
% likely the 1st header
start = [];
nineIndexes = find(in == 9);
if ~isempty(nineIndexes)
    out = find(in(nineIndexes + 1) == biffver);
    if ~isempty(out)
        start = nineIndexes(out(1));
    end
end


function biffvector = exciseE2007Junk(biffvector)
firstByte = 129; secondByte = 0;

%Number of groups of bytes that are used to decide that there is junk.
numGroups = 25;
junkData = zeros(1,4*numGroups);
found = true;
oldIndex = 0;

while (found)
    %Excel seems to sometimes put in regions of junk that look like:  
    % 129 0 0 0 130 0 0 0 131 0 0 0....
    % And then, sometime later, :  1 1 0 0 2 1 0 0 3 1 0 0...
    %The first for loop below initializes the junk data we look for.
    for i = 1:numGroups
        junkData(4*(i-1)+1) = firstByte -1 + i;
        junkData(4*(i-1)+ 2) = secondByte;
    end
    
    %See if we can find 100 bytes that correspond to the junk, starting
    %just beyond the last point we searched to.
    index = oldIndex  + strfind(biffvector(oldIndex+1:end), junkData);
    
    if (isempty(index))
        %Sometimes 254 255 255 255 replaces a 4 byte sequence instead.
        % look for first 4 groups of four, and then the following several
        % groups must be either [firstByte secondByte 0 0] or [254 255 255 255] 
        % or [255 255 255 255]
        index = oldIndex  + strfind(biffvector(oldIndex+1:end), junkData(1:16));
        if ~isempty(index)
            index = index(1);
            movingIndex = index+16;
            for k = 1:numGroups-4
                leftBound = movingIndex + 4*(k - 1);
                garbage1 = all(biffvector(leftBound:leftBound+3) == [254 255 255 255]);
                garbage2 = all(biffvector(leftBound:leftBound+3) == [255 255 255 255]);
                garbage3 = all(biffvector(leftBound:leftBound+3) == [firstByte+3+k secondByte 0 0]);
                if (~garbage1 && ~garbage2 && ~garbage3)
                     found = false;
                     break;
                end
            end
        else
            found = false;
        end
    end
    
    %If junk was found, remove it, and adjust the vector accordingly.
    if (found)
        index = index(1);
        oldIndex = index - 1;
        biffvector = [biffvector(1:index-1) biffvector(index + 512:end)];
        firstByte = firstByte + 128;
        if (firstByte > 256)
            firstByte = firstByte - 256;
            secondByte = secondByte + 1;
        end
    end
end
