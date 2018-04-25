function nitf_metaOut = nitfinfo(filename)
%NITFINFO   Read metadata from NITF file.
%   METADATA = NITFINFO(FILENAME) returns a structure whose fields contain
%   file-level metadata about the images, annotations, and graphics in an
%   NITF file.  FILENAME is a string or character array that specifies the
%   name of the NITF file, which must be in the current directory, in a
%   directory on the MATLAB path, or contain the full path to the file.
%
%   This function supports version 2.0 and 2.1 NITF files at all JITC
%   compliance levels, as well as NSIF 1.0.  NITF 1.1 files are not
%   supported.
%   
%   See also ISNITF, NITFREAD.

%  Copyright 2007-2017 The MathWorks, Inc.


% Parse input arguments.
if (nargin ~= 1)
    error(message('images:nitfinfo:tooFewInputs'))   
end

filename = matlab.images.internal.stringToChar(filename);

% Get details about the file to read.
fileDetails = getFileDetails(filename);

% Ensure the file is NITF and get its version
[valid, nitf_version] = isnitf(fileDetails.Filename);

if (~valid)
    isNIfTI = isnifti(fileDetails.Filename);
    if isNIfTI
        error(message('images:nitfinfo:isNIFTI'))
    else
    error(message('images:nitfinfo:notNITF'))
    end
elseif (~isSupportedVersion(nitf_version))
    error(message('images:nitfinfo:unsupportedVersion', nitf_version))
end

% Open the file.
[fid, msg] = fopen(fileDetails.Filename, 'r');
if (fid < 0)
    error(message('images:nitfinfo:fileOpen', fileDetails.Filename, msg));
end

% Read the metadata.
if (isequal(nitf_version, '2.1'))
    nitf_meta = nitfparse21(fid);
elseif (isequal(nitf_version, '2.0'))
    nitf_meta = nitfparse20(fid);
end

% Close the file
fclose(fid);

%Set up standard data elements 
nitf_metaOut.Filename = fileDetails.Filename;
nitf_metaOut.FileModDate = fileDetails.FileModDate;
nitf_metaOut.FileSize = fileDetails.FileSize;
nitf_metaOut.Format = 'ntf';
nitf_metaOut.FormatVersion = nitf_version;

% Get the meta data into a display-friendly and accessible format
% There are four cases; numerical, alphanumerical, stuctural,
for currElement = 1:numel(nitf_meta)
    fldname = nitf_meta(currElement).vname;
    
    %Handle the case of top level structs such as image subheaders
    if isstruct(nitf_meta(currElement).value)
        tempStruct = ProcessStruct(nitf_meta(currElement).value);
        nitf_metaOut.(fldname) = tempStruct;
    else
        %Scrub the data and capture
        nitf_metaOut.(fldname) = cleandata(nitf_meta(currElement).value, fldname);
    end
end



function structOut = ProcessStruct(structIn)
%This function handles a category heading (such as Images) and its
%immediate substructure.
members = numel(structIn);
for curMember = 1 : members
    fldname = structIn(curMember).vname;
    structOut.(fldname) = structIn(curMember).value;
    
    % Structures require additional processing.
    if isstruct(structOut.(fldname))
        %There's another layer underneath here
        membersL2 = numel(structOut.(fldname));
        
        for curMembersL2 = 1 : membersL2
            fldnameL2 = structIn(curMember).value(curMembersL2).vname;
            structOutL2.(fldnameL2) = (structIn(curMember).value(curMembersL2).value);
            
            %The value may be another layer of structure
            if isstruct(structOutL2.(fldnameL2))
                membersL3 = numel(structOutL2.(fldnameL2));
                
                for curMembersL3 = 1 : membersL3
                    fldnameL3 = structOutL2.(fldnameL2)(curMembersL3).vname;
                    structOutL3.(fldnameL3) = structOutL2.(fldnameL2)(curMembersL3).value;
                    
                    if isstruct(structOutL3.(fldnameL3))
                        %We are down in the image subheader band meta data
                        membersL4 = numel(structOutL3.(fldnameL3));
                        for curMembersL4 = 1 : membersL4
                            fldnameL4 = structOutL3.(fldnameL3)(curMembersL4).vname;
                            structOutL4.(fldnameL4) = (structOutL3.(fldnameL3)(curMembersL4).value);
                            structOutL4.(fldnameL4) = cleandata( structOutL4.(fldnameL4),fldnameL4);
                        end
                        structOutL3.(fldnameL3) = structOutL4;
                        structOutL4 = struct;
                    end
                end
                structOutL2.(fldnameL2) = structOutL3;
                structOutL3 = struct;
            else            
                %Scrub the data
                structOutL2.(fldnameL2) = cleandata(structOutL2.(fldnameL2),fldnameL2); 
            end
        end  
        structOut.(fldname) = structOutL2;
        structOutL2 = struct;
    end
end

    
function details = getFileDetails(filename)

% Verify that the file exists.
[fid, msg] = fopen(filename, 'r');

if (fid == -1)
    fid = openWithExtension(filename);
end

if (fid == -1)
    
    error(message('images:nitfinfo:fileOpen', filename, msg))
    
else
    % File exists.  Get full filename.
    filename = fopen(fid);
    details.Filename = filename;
    d = dir(filename);
    details.FileModDate = d.date;
    details.FileSize = d.bytes;
    fclose(fid);
end


function fid = openWithExtension(filename)

possibleExt = {'nsf', 'NSF', 'ntf', 'NTF'};

for p = 1:numel(possibleExt)
    fid = fopen([filename '.' possibleExt{p}]);
    if (fid ~= -1)
        return
    end
end




function element = cleandata(element, name)
%Clean up the data 
%Strip the spaces and blanks
%Convert numeric data from strings to numbers
if (strcmp(name, 'FileBackgroundColor') || strcmp(name, 'LabelTextColor'))
    element = uint8(element);
    return
end

if contains(name, 'LUTData')
    return
end

if ~isstruct(element)
    if (~isempty(element))
        element = reshape(element, 1, []);
    end

    if (isnumeric(element))
        return
        
    elseif (iscellstr(element) || ischar(element)) 
        element = deblank(element);
    end 
    d = isstrprop(element,'alpha');
    e = isstrprop(element, 'cntrl');
    f = isstrprop(element, 'punct');
    if ~isempty(find(e,1)) 
        element = '';
    end
    
    if isempty(find(d,1)) && ~isempty(element) && isempty(find(f, 1)) && ~contains(name, 'Date')
        if (length(element) < 10)
            element = sscanf(element, '%f');
        else
            element = convertToLargeInt(element);
        end
    end
end


function tf = isSupportedVersion(nitf_version)

tf = isequal(nitf_version, '2.1') || ...
     isequal(nitf_version, '2.0');


function out = convertToLargeInt(in)

% Build up a large number by adding in successive powers of ten from the input value.
out = uint64(0);

ndigits = length(in);
for i=1:ndigits
    out = out + sscanf(in(ndigits - i + 1), '%d') * uint64(10)^(i - 1);
end
