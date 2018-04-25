function denitf_meta = parseDEsubheader20( fid, dataLength )
%PARSEDESUBHEADER20 Parse the Data Extension subheaders in an NITF file.
%   DENITF_META = PARSEDESUBHEADER20
%   Parse the Data Extension Segment Subheader for an NITF 2.0 file.

%   Copyright 2007-2008 The MathWorks, Inc.

denitf_meta = struct([]);
fields = {'DE',       'FilePartType',                    2
          'DESTAG',   'UniqueDESTypeIdentifier',        25
          'DESVER',   'VersionOfTheDataFieldDefinition', 2
          'DESCLAS',  'DESecurityClassification',        1
          'DESCODE',  'DECodewords',                    40
          'DESCTLH',  'DEControlAndHandling',           40
          'DESREL',   'DEReleasingInstructions',        40
          'DESCAUT',  'DEClassificationAuthority',      20
          'DESCTLN',  'DESecurityControlNumber',        20 
          'DESDWNG',  'DESecurityDowngrade',             6};
denitf_meta = nitfReadMeta(denitf_meta, fields, fid);

%DESDWNG is DENITF_META(10) and the last item extracted in the loop above.  Depending
%on its value there will be an DESDEVT 
desdwng = sscanf(denitf_meta(end).value, '%f');
if  desdwng == 999998
    fields = {'DESDEVT', 'DEDowngradingEvent', 40};
    denitf_meta = nitfReadMeta(denitf_meta, fields, fid);
end

%The following is conditional on the value of DESTAG which is denitf_meta(2)
destag = deblank(denitf_meta(2).value);
if strcmp(destag, 'Registered Extensions') || strcmp(destag,'Controlled Extensions')
    fields = {'DESOFLW', 'OverflowedHeaderType', 6
              'DESITEM', 'DataItemOverflowed',   3};
    denitf_meta = nitfReadMeta(denitf_meta, fields, fid);
end

fields = {'DESSHL', 'LengthOfUserDefinedSubheaderFields', 4};
denitf_meta = nitfReadMeta(denitf_meta, fields, fid);

desshl = sscanf(denitf_meta(end).value, '%f');
if desshl ~= 0 % Then we'll have user defined fields
    fields = {'DESSHF', 'UserDefinedSubheaderFields', desshl};
    denitf_meta = nitfReadMeta(denitf_meta, fields, fid);
end

%DESDATA
%Contains either user-defined data or controlled/registered extensions
%Move the cursor through the Extension data
readforwardbytes = sscanf(dataLength, '%f');
fread(fid, readforwardbytes, 'uint8=>char');
