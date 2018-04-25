function TF = isanalyze75(filename)
%ISANALYZE75 Return true for a header file of a Mayo Analyze 7.5 data set.
%
%   TF = ISANALYZE75(FILENAME) returns TRUE if FILENAME is a header file of
%   a Mayo Analyze 7.5 data set. 
%
%   FILENAME is considered to be a valid header file of a Mayo Analyze 7.5
%   data set if the header size is 348 bytes.
%
%   Example
%   -------  
%   TF = isanalyze75('brainMRI.hdr');
%
%   See also ANALYZE75INFO, ANALYZE75READ.

%   Copyright 2005-2015 The MathWorks, Inc.



% Check if filename is a string.
if ~isa(filename,'char')
    error(message('images:isanalyze75:invalidInputArgument'))
end
    
% Open the HDR file
fid  = analyze75open(filename, 'hdr', 'r');

% Check headerSize
TF = validateHeaderSize(fid, filename);

% Close the file
fclose(fid);



%%%
%%% Function validateHeaderSize
%%%
function TF = validateHeaderSize(fid, filename)

% Analyze 7.5 format standard header size
analyzeHeader = int32(348);
% Interfile header - swapbytes(typecast(uint8('!INT'), 'int32'))
interfileHeader = int32(558452308); 
% Possible extended header size
extendedRange = int32([348 2000]);

% Read headerSize.
headerSize = fread(fid, 1, 'int32=>int32');
swappedHeaderSize = swapbytes(headerSize);

% Compare with Standard Analyze 7.5 headerSize. 
if ((headerSize == analyzeHeader)||(swappedHeaderSize == analyzeHeader))
    TF = true;
% Compare with Interfile header 
elseif ((headerSize == interfileHeader) || ...
        (swappedHeaderSize == interfileHeader))
    TF = false;
% Check for extended headerSize  
elseif ((headerSize > extendedRange(1)) ... 
    && (headerSize < extendedRange(2))) ...
    || ((swappedHeaderSize > extendedRange(1)) ...
    && (swappedHeaderSize < extendedRange(2)))
     % Return true but warn that this may not be a valid Analyze 7.5 file
     TF = true;
     warning(message('images:isanalyze75:incorrectHeaderSize', filename'));   
% Invalid headerSize    
else
    TF = false;    
end






