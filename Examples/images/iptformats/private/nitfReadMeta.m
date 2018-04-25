function meta = nitfReadMeta(meta, fieldsTable, fid)
%nitfReadMeta   Append attributes to metadata structure.
%    OUTMETA = nitfReadMeta(INMETA, FIELDSTABLE, FID) reads attributes
%    from the file with handle FID and append it to INMETA the metadata
%    structure.  The FIELDSTABLE cell array contains details about the
%    attributes, such as short names, long names, and data length.

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
    
    meta(metaOffset + p).name = fieldsTable{p,1};
    meta(metaOffset + p).vname = fieldsTable{p,2};
    meta(metaOffset + p).value = data(start:stop);
    
    dataOffset = stop;
    
end
