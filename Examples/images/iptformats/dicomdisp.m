function dicomdisp(filename, varargin)
%DICOMDISP  Display DICOM file structure.
%   DICOMDISP(FILENAME) reads the metadata from the compliant DICOM file
%   specified in the string or character vector FILENAME and prints it.
%
%   DICOMDISP(FILENAME, 'dictionary', D) uses the data dictionary
%   file given in the string or character vector D to read the DICOM file.
%   The file in D must be on the MATLAB search path.  The default value is
%   "dicom-dict.txt".
%
%   DICOMDISP(..., 'UseVRHeuristic', TF) instructs the parser to use a
%   heuristic to help read certain noncompliant files which switch value
%   representation (VR) modes incorrectly. A warning will be displayed if
%   the heuristic is employed. When TF is true (the default), a small
%   number of compliant files will not be read correctly. Set TF to false
%   to read these compliant files.
%
%   Example:
%
%     dicomdisp('CT-MONO2-16-ankle.dcm');
%
%   See also DICOMINFO, DICOMREAD, DICOMWRITE, DICOMDICT, DICOMUID.

% Copyright 2006-2017 The MathWorks, Inc.

% This function (along with DICOMREAD) implements the M-READ service.
% This function implements the M-INQUIRE FILE service.

filename = matlab.images.internal.stringToChar(filename);
varargin = matlab.images.internal.stringToChar(varargin);

args = parseInputs(filename, varargin{:});
filename = getFullPathToFile(filename);
dictionaryResetter = setDictionary(args); %#ok<NASGU>

if (isdicom(filename))
    fileDetails = dicom_getFileDetails(filename);
    rawAttributes = parseFile(fileDetails, args);
    
    printFileDetails(fileDetails, rawAttributes);
    printAttributeTable(rawAttributes)
else
    error(message('images:dicomdisp:notDICOM'))
end


function dictionaryResetter = setDictionary(args)

dicomdict('set_current', args.Dictionary)
dictionaryResetter = onCleanup(@() dicomdict('reset_current'));


function rawAttributes = parseFile(fileDetails, args)

readPixels = false;
rawAttributes = images.internal.dicom.dicomparse(fileDetails.name, ...
                           fileDetails.bytes, ...
                           getEndian(), ...
                           readPixels, ...
                           dicomdict('get'), ...
                           args.UseVRHeuristic);

                       
function filename = getFullPathToFile(filename)

fid = fopen(filename);
if (fid < 0)
    error(message('images:dicomdisp:fileNotFound', filename));
end

filename = fopen(fid);
fclose(fid);


function printFileDetails(fileDetails, rawAttributes)

printOneLine('images:dicomdisp:filenameAndSize', fileDetails.name, fileDetails.bytes)

printEndian()

if (hasFileMetadata(rawAttributes))
    printOneLine('images:dicomdisp:hasGroup0002', rawAttributes(1).Location);
    printFileTransferDetails(rawAttributes)
else
    printOneLine('images:dicomdisp:noGroup0002');
end

printInformationObjectDetails(rawAttributes)

disp(' ')


function printAttributeTable(rawAttributes)

printTableHeader();

startLevel = 0;
printAttributes(rawAttributes, startLevel);


function tf = hasFileMetadata(rawAttributes)

fileMetadataGroup = 2;
tf = rawAttributes(1).Group == fileMetadataGroup;


function printFileTransferDetails(rawAttributes)

idx = findTransferSyntaxAttribute(rawAttributes);
if (~isempty(idx))
    [txfrUID, txfrName] = getUIDDetails(rawAttributes(idx));
    printOneLine('images:dicomdisp:transferSyntaxValue', txfrUID, txfrName);
else
    printOneLine('images:dicomdisp:noTransferSyntax');
end


function printInformationObjectDetails(rawAttributes)

idx = findSOPClassUIDAttribute(rawAttributes);
if (~isempty(idx))
    [SOPClassUID, SOPClassName] = getUIDDetails(rawAttributes(idx));
    printOneLine('images:dicomdisp:iodUIDAndName', SOPClassUID, SOPClassName)
else
    printOneLine('images:dicomdisp:unknownUID')
end


function idx = findTransferSyntaxAttribute(rawAttributes)

idx = find(([rawAttributes(:).Group] == 2) & ([rawAttributes(:).Element] == 16));


function idx = findSOPClassUIDAttribute(rawAttributes)

idx = find(([rawAttributes(:).Group] == 8) & ([rawAttributes(:).Element] == 22));


function [UID, name] = getUIDDetails(txfrAttribute)

UID = trimWhitespace(txfrAttribute.Data);
uidDetails = dicom_uid_decode(UID);
name = uidDetails.Name;


function trimmedText = trimWhitespace(originalText)

trimmedText = deblank(char(originalText));
trimmedText(trimmedText == 0) = '';


function printOneLine(msgID, varargin)

msgObject = message(msgID, varargin{:});
disp(msgObject.getString())


function printEndian()

if (isequal(getEndian(), 'L'))
    printOneLine('images:dicomdisp:readLittleEndian');
else
    printOneLine('images:dicomdisp:readBigEndian');
end


function printTableHeader

header = buildHeaderString();
fprintf('%s\n', header);
disp(repmat('-', [1 100]))


function headerString = buildHeaderString

persistent formatString

if (~isempty(formatString))
    headerString = formatString;
    return
end

headerDetailsTable = getColumnDetails();

formatString = '';

for headerColumn = 1:size(headerDetailsTable, 1)
    
    headerLabel = headerDetailsTable{headerColumn, 1};
    headerColumnWidth = max(headerDetailsTable{headerColumn, 3}, length(headerLabel));
    justification = headerDetailsTable{headerColumn, 4};
    
    switch (justification)
        case {'left', 'left-big'}
            formatString = [formatString headerLabel]; %#ok<AGROW>
            formatString = [formatString repmat(' ', [1, headerColumnWidth - length(headerLabel) + 1])]; %#ok<AGROW>
            
        case 'centered'
            [leftPad, rightPad] = getPadding(length(headerLabel), headerColumnWidth);
            formatString = [formatString leftPad headerLabel rightPad ' ']; %#ok<AGROW>
            
        case 'full'
            formatString = [formatString headerLabel ' ']; %#ok<AGROW>
    end
end

headerString = formatString;


function columnDetailsTable = getColumnDetails

columnDetailsTable = {
    message('images:dicomdisp:location').getString(), '%07ld', 7, 'left'
    message('images:dicomdisp:level').getString(), '%2d', 2, 'centered'
    message('images:dicomdisp:tag').getString(), '(%04X,%04X)', 11, 'centered'
    'VR', '%2s', 2, 'full'
    message('images:dicomdisp:size').getString(), '%10.0f %-s', getWidthOfSizeColumn(), 'centered'
    ' ', '-', 1, 'full'
    message('images:dicomdisp:name').getString(), '%-32s', 32, 'left-big'
    message('images:dicomdisp:data').getString(), '%s', 50, 'left-big'};


function width = getWidthOfSizeColumn

width = 10 + 1 + length(message('images:dicomdisp:bytes').getString());


function printAttributes(rawAttributes, level)

for idx = 1:numel(rawAttributes)
    
    currentAttr = rawAttributes(idx);
    currentAttr = updateVR(currentAttr);
    
    data = getDataString(currentAttr);
    
    printOne(currentAttr, data, level)
    
    if (isSequenceOfAttributes(currentAttr))
        printAttributes(getNestedAttributes(currentAttr), level + 1);
    end
    
end


function currentAttr = updateVR(currentAttr)

if (isempty(currentAttr.VR))
    currentAttr.VR = '""';
end


function data = getDataString(currentAttr)

if (isempty(currentAttr.Data))
    data = '[]';
elseif (numel(currentAttr.Data) > 1e6)
    data = getTextForBinary();
elseif (isstruct(currentAttr.Data))
    data = '';
elseif (hasNonASCII(currentAttr.Data))
    data = getTextForBinary();
else
    data = sprintf('[%s]', char(currentAttr.Data));
end


function tf = hasNonASCII(data)

printableASCIIRange = [32 126];
tf = any(data(1:end-1) < printableASCIIRange(1)) || ... % Use end-1 to accomodate whitespace.
     any(data > printableASCIIRange(2));


function tf = isSequenceOfAttributes(currentAttr)

tf = isstruct(currentAttr.Data);


function sequenceData = getNestedAttributes(currentAttr)

sequenceData = currentAttr.Data;


function printOne(attr, data, level)

dictionary = dicomdict('get_current');

% Display the attribute: '%07ld  %3d   (%04X,%04X) %2s %10.0f %-5s - %-32s %s\n'
fprintf(buildFormatString(), ...
        attr.Location, ...
        level, ...
        attr.Group, ...
        attr.Element, ...
        attr.VR, ...
        attr.Length, ...
        message('images:dicomdisp:bytes').getString(), ...
        images.internal.dicom.lookupActions(attr.Group, attr.Element, dictionary), ...
        data);


function outputString = buildFormatString

persistent formatString

if (~isempty(formatString))
    outputString = formatString;
    return
end

columnDetailsTable = getColumnDetails();

formatString = '';

for column = 1:size(columnDetailsTable, 1)
    
    headerLabel = columnDetailsTable{column, 1};
    formatSpecifier = columnDetailsTable{column, 2};
    dataWidth = columnDetailsTable{column, 3};
    justification = columnDetailsTable{column, 4};
    
    switch (justification)
        case {'left', 'full'}
            rightPad = repmat(' ', [1, abs(length(headerLabel) - dataWidth)]);
            formatString = [formatString formatSpecifier rightPad ' ']; %#ok<AGROW>
            
        case {'left-big'}
            formatString = [formatString formatSpecifier ' ']; %#ok<AGROW>
            
        case 'centered'
            [leftPad, rightPad] = getPadding(dataWidth, length(headerLabel));
            formatString = [formatString leftPad formatSpecifier rightPad ' ']; %#ok<AGROW>
            
    end
end

formatString = [formatString '\n'];
outputString = formatString;


function [leftPad, rightPad] = getPadding(substringWidth, columnWidth)

paddingSize = columnWidth - substringWidth;

if (paddingSize > 0)
    leftPad = repmat(' ', [1, floor(paddingSize / 2)]);
    rightPad = repmat(' ', [1, ceil(paddingSize / 2)]);
else
    leftPad = '';
    rightPad = '';
end


function byteOrder = getEndian

persistent endian

if (~isempty(endian))
  byteOrder = endian;
  return
end

[~, ~, endian] = computer;
byteOrder = endian;


function args = parseInputs(filename, varargin)

args.Dictionary = dicomdict('get');
args.UseVRHeuristic = true;

validateattributes(filename,{'char'}, {'row', 'nonempty'}, mfilename, 'filename', 1)

switch (numel(varargin))
    case 0
    case {2,4}
        paramStrings = {'Dictionary', 'UseVRHeuristic'};
        
        for k = 1:2:numel(varargin)
            field = validatestring(varargin{k}, paramStrings, k);
            args.(field) = varargin{k+1};
        end
    otherwise
        error(message('images:dicomdisp:badNargin'))
end


function str = getTextForBinary()

persistent binaryString
if isempty(binaryString)
    binaryString = message('images:dicomdisp:binary').getString();
end

str = binaryString;