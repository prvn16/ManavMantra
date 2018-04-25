function renitf_meta = parseREsubheader20( fid, dataLength, headerLength )
%PARSERESUBHEADER20 Process the Reserved Extensions subheaders in an NITF20 file.
%   RENITF_META = PARSERESUBHEADER20
%   Parse the Reserved Extension Segment Subheader for an NITF 2.0 file.

%   Copyright 2007-2008 The MathWorks, Inc.

%   Essentially we don't know anything about the extension so we just need
%   to pull the header into a struct and read ahead over the data

% Convert the length from a decimal string to an integer.
headerLength = sscanf(headerLength', '%d');

renitf_meta = struct([]);
fields = {'ReservedDataExtensionHeader', 'ReservedDataExtensionHeader', headerLength};
renitf_meta = nitfReadMeta(renitf_meta, fields, fid);

%Move the cursor through the Reserved Extension data
readforwardbytes = sscanf(dataLength, '%f');
fread(fid, readforwardbytes, 'uint8=>char');
