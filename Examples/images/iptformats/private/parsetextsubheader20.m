function tsnitf_meta = parsetextsubheader20( fid, dataLength )
%PARSETEXTSUBHEADER20 Parse the Text subheaders in an NITF file.
%   TSNITF_META = PARSETEXTSUBHEADER20
%   Parse the Text Segment Subheader for an NITF 2.0 file.

%   Copyright 2007-2008 The MathWorks, Inc.

tsnitf_meta = struct([]);
fields = {'TE',       'FilePartType',                 2
          'TEXTID',   'TextID',                      10
          'TXTDT',    'TextDateAndTime',             14
          'TXTITL',   'TextTitle',                   80
          'TSCLAS',   'TextSecurityClassification',   1
          'TSCODE',   'TextCodewords',               40
          'TSCTLH',   'TextControlAndHandling',      40
          'TSREL',    'TextReleasingInstructions',   40
          'TSCAUT',   'TextClassificationAuthority', 20
          'TSCTLN',   'TextSecurityControlNumber',   20
          'TSDWNG',   'TextSecurityDowngrade',        6};
tsnitf_meta = nitfReadMeta(tsnitf_meta, fields, fid);

%TSDWNG is TSNITF_META(11) and the last item extracted in the loop above.  Depending
%on its value there will be an TSDEVT 
tsdwng = sscanf(tsnitf_meta(end).value, '%f');
if  tsdwng == 999998
    fields = {'TSDEVT', 'TextDowngradingEvent', 40};
    tsnitf_meta = nitfReadMeta(tsnitf_meta, fields, fid);
end

%ENCRYP
fields = {'ENCRYP', 'Encryption', 1
          'TXTFMT', 'TextFormat', 3
          'TXSHDL', 'ExtendedSubheaderDataLength', 5};
tsnitf_meta = nitfReadMeta(tsnitf_meta, fields, fid);

txshdl = sscanf(tsnitf_meta(end).value, '%f');
if txshdl ~= 0
    fields = {'TXSOFL', 'ExtendedSubheaderOverflow', 3
              'TXSHD',  'ExtendedSubheaderData',     txshdl - 3};
    tsnitf_meta = nitfReadMeta(tsnitf_meta, fields, fid);
end

%Move the cursor through the Text data
readforwardbytes = sscanf(dataLength, '%f');
fread(fid, readforwardbytes, 'uint8=>char');
