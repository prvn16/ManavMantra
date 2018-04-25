function gsnitf_meta = parsegraphicsubheader( fid, dataLength )
%PARSEGRAPHICSUBHEADER Parse the Graphic subheaders in an NITF file.
%   GSNITF_META = PARSEGRAPHICSUBHEADER
%   Parse the Graphic Segment Subheader for an NITF 2.1 file.

%   Copyright 2007-2008 The MathWorks, Inc.

%  Initialize the graphic subheader structure
gsnitf_meta = struct([]);
fields = {'SY',       'FilePartType',                          2
          'SID',      'GraphicID',                            10
          'SNAME',    'GraphicName',                          20
          'SSCLAS',   'GraphicSecurityClassification',         1
          'SSCLSY',   'GraphicSecurityClassificationSystem',   2
          'SSCODE',   'GraphicCodewords',                     11
          'SSCTLH',   'GraphicControlAndHandling',             2
          'SSREL',    'GraphicReleasingInstructions',         20
          'SSDCTP',   'GraphicDeclassificationType',           2
          'SSDCDT',   'GraphicDeclassificationDate',           8
          'SSDCXM',   'GraphicDeclassificationExemption',      4
          'SSDG',     'GraphicDowngrade',                      1
          'SSDGT',    'GraphicDowngradeDate',                  8
          'SSCLTX',   'GraphicClassificationText',            43
          'SSCATP',   'GraphicClassificationAuthorityType',    1
          'SSCAUT',   'GraphicClassificationAuthority',       40
          'SSCRSN',   'GraphicClassificationReason',           1
          'SSSRDT',   'GraphicSecuritySourceDate',             8
          'SSCTLN',   'GraphicSecurityControlNumber',         15
          'ENCRYP',   'Encryption',                            1
          'STYPE',    'GraphicType',                           1
          'SRES1',    'ReservedForFutureUse',                 13
          'SDLVL',    'DisplayLevel',                          3
          'SALVL',    'GraphicAttachmentLevel',                3
          'SLOC',     'GraphicLocation',                      10
          'SBND1',    'FirstGraphicBoundLocation',            10
          'SCOLOR',   'GraphicColor',                          1
          'SBND2',    'SecondGraphicBoundLocation',           10
          'SRES2',    'ReservedForFutureUse',                  2
          'SXSHDL',   'ExtendedSubheaderDataLength',           5};
gsnitf_meta = nitfReadMeta(gsnitf_meta, fields, fid);

%SXSHDL is GSNITF_META(30) and the last item extracted in the loop above.  Depending
%on its value there will be an SXSOFL or Extended Subheader Overflow field and SXSHD field.
%If SXSHDL is not zeros, add the SXSOFL and SXSHD fields to the meta data struct
%and insert values.

sxshdl = sscanf(gsnitf_meta(30).value, '%f');
if sxshdl ~= 0
    fields = {'SXSOFL', 'ExtendedSubheaderOverflow', 3
              'SXSHD', 'ExtendedSubheaderData', sxshdl - 3};
    gsnitf_meta = nitfReadMeta(gsnitf_meta, fields, fid);
end


%Move the cursor through the graphic data
readforwardbytes = sscanf(dataLength, '%f');
fread(fid, readforwardbytes, 'uint8=>char');
