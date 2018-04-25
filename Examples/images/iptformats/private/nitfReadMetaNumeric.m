function meta = nitfReadMetaNumeric(meta, fieldsTable, fid)
%nitfReadMetaNumeric  Append attributes to metadata structure.
%    OUTMETA = nitfReadMetaNumeric(INMETA, FIELDSTABLE, FID) reads
%    numeric attributes from the file with handle FID and append it to
%    INMETA the metadata structure.  The FIELDSTABLE cell array contains
%    details about the attributes:
%
%      * Column 1: short names
%      * Column 2: long names
%      * Column 3: number of elements (not number of bytes)
%      * Column 4: datatype

%   Copyright 2009 The MathWorks, Inc.

% For the sake of performance, pre-allocate storage for the new
% attributes and then insert attributes into the pre-sized struct array.
% Use "offset" to facilitate adding the new attributes.
metaOffset = numel(meta);
numToAppend = size(fieldsTable, 1);

meta(metaOffset + numToAppend).value = '';

% As an optimization, convert the lengths part of the cell array to a
% numeric array.
dataLengths = [fieldsTable{:,3}];

% Read and insert the new attributes.
for p = 1:numToAppend
    
    meta(metaOffset + p).name = fieldsTable{p,1};
    meta(metaOffset + p).vname = fieldsTable{p,2};
    meta(metaOffset + p).value = fread(fid, dataLengths(p), fieldsTable{p,4}, 'ieee-be');
    
end
