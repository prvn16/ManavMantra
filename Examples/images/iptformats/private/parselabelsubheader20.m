function lsnitf_meta = parselabelsubheader20( fid, dataLength )
%PARSELABELSUBHEADER20 Parse the Label subheaders in an NITF file.
%   LSNITF_META = PARSELABELSUBHEADER20
%   Parse the Label Segment Subheader for an NITF 2.0 file.

%   Copyright 2007-2008 The MathWorks, Inc.

lsnitf_meta = struct([]);
fields = {'LA',      'FilePartType',                   2
          'LID',     'LabelID',                       10
          'LSCLAS',  'LabelSecurityClassification',    1
          'LSCODE',  'LabelCodewords',                40
          'LSCTLH',  'LabelControlAndHandling',       40
          'LSREL',   'LabelReleasingInstructions',    40
          'LSCAUT',  'LabelClassificationAuthority',  20
          'LSCTLN',  'LabelSecurityControlNumber',    20
          'LSDWNG',  'LabelSecurityDowngrade',         6};
lsnitf_meta = nitfReadMeta(lsnitf_meta, fields, fid);

%LSDWNG is LSnitf_meta(9) and the last item extracted in the loop above.  Depending
%on its value there will be an SSDEVT 
lsdwng = sscanf(lsnitf_meta(end).value, '%f');
if  lsdwng == 999998
    fields = {'LSDEVT', 'LabelDowngradingEvent', 40};
    lsnitf_meta = nitfReadMeta(lsnitf_meta, fields, fid);
end

fields = {'ENCRYP', 'Encryption', 1
          'LFS', 'LabelFontStyle', 1
          'LCW', 'LabelCellWidth', 2
          'LCH', 'LabelCellHeight', 2
          'LDLVL', 'DisplayLevel', 3
          'LALVL', 'LabelAttachmentLevel', 3
          'LLOC', 'LabelLocation', 10
          'LTC', 'LabelTextColor', 3
          'LBC', 'LabelBackgroundColor', 3
          'LXSHDL', 'ExtendedSubheaderDataLength', 5};
lsnitf_meta = nitfReadMeta(lsnitf_meta, fields, fid);

%LXSOFL and LCSHD
lxshdl = sscanf(lsnitf_meta(end).value, '%f');
if lxshdl ~= 0
    fields = {'LXSOFL', 'ExtendedSubheaderOverflow', 3
              'LXSHD',  'ExtendedSubheaderData',     lxshdl - 3};
    lsnitf_meta = nitfReadMeta(lsnitf_meta, fields, fid);
end

%Move the cursor through the Label data
readforwardbytes = sscanf(dataLength, '%f');
fread(fid, readforwardbytes, 'uint8=>char');
