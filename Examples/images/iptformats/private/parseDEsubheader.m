function [ denitf_meta ] = parseDEsubheader( fid, dataLength )
%PARSEDESUBHEADER Parse the Data Extension subheaders in an NITF file.
%   DENITF_META = PARSEDESUBHEADER
%   Parse the Data Extension Segment Subheader for an NITF 2.1 file.

%   Copyright 2007-2008 The MathWorks, Inc.

denitf_meta = struct([]);
fields = {'DE',       'FilePartType',                    2
          'DESTAG',   'UniqueDESTypeIdentifier',        25
          'DESVER',   'VersionOfTheDataFieldDefinition', 2
          'DESCLAS',  'DESecurityClassification',        1
          'DESCLSY',  'DESecurityClassificationSystem',  2
          'DESCODE',  'DECodewords',                    11
          'DESCTLH',  'DEControlAndHandling',            2
          'DESREL',   'DEReleasingInstructions',        20
          'DESDCTP',  'DEDeclassificationType',          2
          'DESDCDT',  'DEDeclassificationDate',          8
          'DESDCXM',  'DEDeclassificationExemption',     4
          'DESDG',    'DEDowngrade',                     1
          'DESDGT',   'DEDowngradeDate',                 8
          'DESCLTX',  'DEClassificationText',           43
          'DESCATP',  'DEClassificationAuthorityType'    1
          'DESCAUT',  'DEClassificationAuthority',      40
          'DESCRSN',  'DEClassificationReason',          1
          'DESSRDT',  'DESecuritySourceDate',            8
          'DESCTL',   'DESecurityControlNumber',        15};
denitf_meta = nitfReadMeta(denitf_meta, fields, fid);

% DESOFLW is present if DESTAG = TRE_OVERFLOW.
if (isequal(deblank(denitf_meta(2).value), 'TRE_OVERFLOW'))

    fields = {'DESOFLW', 'OverflowedHeaderType', 6
              'DESITEM', 'DataItemOverflowed',   3};
    denitf_meta = nitfReadMeta(denitf_meta, fields, fid);

end

%DESSHL
fields = {'DESSHL', 'LengthOfUserDefinedSubheaderFields', 4};
denitf_meta = nitfReadMeta(denitf_meta, fields, fid);

desshl = sscanf(denitf_meta(end).value, '%f');
if desshl ~= 0 % The we'll have user defined fields
    fields = {'DESSHF', 'UserDefinedSubheaderFields', desshl};
    denitf_meta = nitfReadMeta(denitf_meta, fields, fid);
end

%DESDATA
%Contains either user-defined data or controlled/registered extensions
%Move the cursor through the Extension data.  Return as raw bytes.
readforwardbytes = sscanf(dataLength, '%f');

denitf_meta(end + 1).name = 'DESDATA';
denitf_meta(end).vname = 'UserDefinedData';
denitf_meta(end).value = fread(fid, readforwardbytes, 'uint8=>uint8');
