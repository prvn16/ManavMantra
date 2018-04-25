function gsnitf_meta = parsegraphicsubheader20( fid, dataLength )
%PARSEGRAPHICSUBHEADER Parse the Graphic subheaders in an NITF file.
%   GSNITF_META = PARSEGRAPHICSUBHEADER20
%   Parse the Graphic Segment Subheader for an NITF 2.0 file.

%   Copyright 2007-2008 The MathWorks, Inc.

%  Initialize the graphic subheader structure
gsnitf_meta = struct([]);
fields = {'SY',        'FilePartType',                   2
          'SID',       'SymbolID',                      10
          'SNAME',     'SymbolName',                    20
          'SSCLAS',    'SymbolSecurityClassification',   1
          'SSCODE',    'SymbolCodewords',               40
          'SSCTLH',    'SymbolControlAndHandling',      40
          'SSREL',     'SymbolReleasingInstructions',   40
          'SSCAUT',    'SymbolClassificationAuthority', 20
          'SSCTLN',    'SymbolSecurityControlNumber',   20
          'SSDWNG',    'SymbolSecurityDowngrade',        6};
gsnitf_meta = nitfReadMeta(gsnitf_meta, fields, fid);

%SSDWNG is GSNITF_META(10) and the last item extracted in the loop above.  Depending
%on its value there will be an SSDEVT 
ssdwng = sscanf(gsnitf_meta(end).value, '%f');
if  ssdwng == 999998

    fields = {'SSDEVT', 'SymbolDowngradingEvent', 40};
    gsnitf_meta = nitfReadMeta(gsnitf_meta, fields, fid);
    
end

fields = {'ENCRYP', 'Encryption', 1
          'STYPE', 'SymbolType', 1
          'NLIPS', 'NumberOfLinesPerSymbol', 4
          'NPIXPL', 'NumberOfPixelsPerLine' 4
          'NWDTH', 'LineWidth', 4
          'NBPP', 'NumberOfBitsPerPixel', 1
          'SDLVL', 'DisplayLevel', 3
          'SALVL', 'SymbolAttachmentLevel', 3
          'SLOC', 'SymbolLocation', 10
          'SLOC2', 'SecondSymbolLocation', 10
          'SCOLOR', 'SymbolColor', 1
          'SNUM', 'SymbolNumber', 6
          'SROT', 'SymbolRotation', 3
          'NELUT', 'NumberOfLUTEntries', 3};
gsnitf_meta = nitfReadMeta(gsnitf_meta, fields, fid);


%DLUT -- This is the actual look-up table which I think constitutes data
%           Should we expose it as metadata?
nelut = sscanf(gsnitf_meta(end).value, '%f');
if nelut ~= 0
    if strcmp(scolor,'C') %Color look-up table
        dlutsize = 3 * nelut;
    elseif strcmp(scolor,'G') %Gray scale look-up table
        dlutsize = nelut;
    else
        dlutsize = 0;
    end

    fields = {'DLUT', 'SymbolLUTData', dlutsize};
    gsnitf_meta = nitfReadMeta(gsnitf_meta, fields, fid);
end

fields = {'SXSHDL', 'ExtendedSubheaderDataLength', 5};
gsnitf_meta = nitfReadMeta(gsnitf_meta, fields, fid);

%SXSOFL and SCSHD
sxshdl = sscanf(gsnitf_meta(end).value, '%f');
if sxshdl ~= 0
    fields = {'SXSOFL', 'ExtendedSubheaderOverflow', 3
              'SXSHD', 'ExtendedSubheaderData', sxshdl - 3};
    gsnitf_meta = nitfReadMeta(gsnitf_meta, fields, fid);
end

%Move the cursor through the graphic data
readforwardbytes = sscanf(dataLength, '%f');
fread(fid, readforwardbytes, 'uint8=>char');
