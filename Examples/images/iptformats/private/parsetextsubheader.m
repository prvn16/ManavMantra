function tsnitf_meta = parsetextsubheader( fid, dataLength )
%PARSETEXTSUBHEADER Parse the Text subheaders in an NITF file.
%   TSNITF_META = PARSETEXTSUBHEADER
%   Parse the Text Segment Subheader for an NITF 2.1 file.

%   Copyright 2007-2008 The MathWorks, Inc.

tsnitf_meta = struct([]);
fields = {'TE',      'FilePartType',                       2
          'TEXTID',   'TextID',                            7
          'TXTALVAL', 'TextAttachmentLevel',               3
          'TXTDT',    'TextDateAndTime',                  14
          'TXTITL',   'TextTitle',                        80
          'TSCLAS',   'TextSecurityClassification',        1
          'TSCLSY',   'TextSecurityClassificationSystem',  2
          'TSCODE',   'TextCodewords',                    11
          'TSCTLH',   'TextControlAndHandling',            2
          'TSREL',    'TextReleasingInstructions',        20
          'TSDCTP',   'TextDeclassificationType',          2
          'TSDCDT',   'TextDeclassificationDate',          8
          'TSDCXM',   'TextDeclassificationExemption',     4
          'TSDG',     'TextDowngrade',                     1
          'TSDGT',    'TextDowngradeDate',                 8
          'TSCLTX',   'TextClassificationText',           43
          'TSCATP',   'TextClassificationAuthorityType',   1
          'TSCAUT',   'TextClassificationAuthority',      40
          'TSCRSN',   'TextClassificationReason',          1
          'TSSRDT',   'TextSecuritySourceDate',            8
          'TSCTLN',   'TextSecurityControlNumber',        15
          'ENCRYP',   'Encryption',                        1 
          'TXTFMT',   'TextFormat',                        3
          'TXSHDL',   'ExtendedSubheaderDataLength',       5};
tsnitf_meta = nitfReadMeta(tsnitf_meta, fields, fid);

%TXSHDL is TSMETA_INFO(24) and the last item extracted in the loop above.  Depending
%on its value there will be an TXSOFL or Extended Subheader Overflow field and TXSHD field.
%If TXSHDL is not zeros, add the TXSOFL and TXSHD fields to the meta data struct
%and insert values.
txshdl = sscanf(tsnitf_meta(24).value, '%f');
if txshdl ~= 0
    fields = {'TXSOFL', 'ExtendedSubheaderOverflow', 3
              'TXSHD',  'ExtendedSubheaderData',     txshdl - 3};
    tsnitf_meta = nitfReadMeta(tsnitf_meta, fields, fid);
end

%Move the cursor through the Text data
readforwardbytes = sscanf(dataLength, '%f');
fread(fid, readforwardbytes, 'uint8=>char');
