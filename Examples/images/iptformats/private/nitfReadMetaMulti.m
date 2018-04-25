function meta = nitfReadMetaMulti(meta, fieldsTable, fid, index)
%nitfReadMetaMulti   Append attributes to metadata structure.
%    OUTMETA = nitfReadMetaMulti(INMETA, FIELDSTABLE, FID, INDEX) reads
%    attributes from the file with handle FID and append it to INMETA the
%    metadata structure.  The FIELDSTABLE cell array contains details
%    about the attributes, such as short names, long names, and data
%    length.  Unlike nitfReadMeta() the .name and .vname fields are
%    templates with sprintf() patterns.

%   Copyright 2008 The MathWorks, Inc.

% For the sake of performance, pre-allocate storage for the new
% attributes and then insert attributes into the pre-sized struct array.
% Use "offset" to facilitate adding the new attributes.
metaOffset = numel(meta);
numToAppend = size(fieldsTable, 1);

meta(metaOffset + numToAppend).value = '';

% As an optimization, convert the lengths part of the cell array to a
% numeric array.
dataLengths = [fieldsTable{:,3}];

% Read all of the data at once.  Extract individual values in the loop.
data = fread(fid, sum(dataLengths), 'uint8=>char')';

% Insert the new attributes.
dataOffset = 0;
for p = 1:numToAppend
    
    start = dataOffset + 1;
    stop  = dataOffset + dataLengths(p);
    
    meta(metaOffset + p).name = sprintf(fieldsTable{p,1}, index);
    meta(metaOffset + p).vname = sprintf(fieldsTable{p,2}, index);
    meta(metaOffset + p).value = data(start:stop);
    
    dataOffset = stop;
    
end
