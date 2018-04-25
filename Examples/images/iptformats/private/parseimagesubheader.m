function isnitf_meta = parseimagesubheader( fid, dataLength )
%PARSEIMAGESUBHEADER Parse the Image subheaders in an NITF file.
%   ISNITF_META = PARSEIMAGESUBHEADER
%   Parse the Image Segment Subheader for an NITF 2.1 file.

%   Copyright 2007-2009 The MathWorks, Inc.

% TODO: refactor common functions between 2.0 and 2.1 into an external file

%  Initialize the image subheader structure
isnitf_meta = struct([]);
fields = {'IM',      'FilePartType',                       2
          'IID1',    'ImageID1',                          10
          'IDATIM',  'ImageDateAndTime',                  14
          'TGTID',   'TargetID',                          17
          'IID2',    'ImageIID2',                         80
          'ISCLAS',  'ImageSecurityClassification',        1
          'ISCLSY',  'ImageSecurityClassificationSystem',  2
          'ISCODE',  'ImageCodewords',                    11
          'ISCTLH',  'ImageControlAndHandling',            2
          'ISREL',   'ImageReleasingInstructions',        20
          'ISDCTP',  'ImageDeclassificationType',          2
          'ISDCDT',  'ImageDeclassificationDate',          8
          'ISDCXM',  'ImageDeclassificationExemption',     4
          'ISDG',    'ImageDowngrade',                     1
          'ISDGT',   'ImageDowngradeDate',                 8
          'ISCLTX',  'ImageClassificationText',           43
          'ISCATP',  'ImageClassificationAuthorityType',   1
          'ISCAUT',  'ImageClassificationAuthority',      40
          'ISCRSN',  'ImageClassificationReason',          1
          'ISSRDT',  'ImageSecuritySourceDate',            8
          'ISCTLN',  'ImageSecurityControlNumber',        15
          'ENCRYP',  'Encryption',                         1
          'ISORCE',  'ImageSource',                       42
          'NROWS',   'NumberOfSignificantRowsInImage',     8
          'NCOLS',   'NumberOfSignificantColumnsInImage',  8
          'PVTYPE',  'PixelValueType',                     3
          'IREP',    'ImageRepresentation',                8
          'ICAT',    'ImageCategory',                      8
          'ABPP',    'ActualBitsPerPixelPerBand',          2
          'PJUST',   'PixelJustification',                 1
          'ICORDS',  'ImageCoordinateSystem',              1};
isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);

%ICORDS is the last item extracted in the loop above.  Depending
%on its value there will be an IGEOLO or Image Geographic Location field.
%If ICORDS is not a space, add the IGEOLO field to the meta data struct
%and insert values.
icords = deblank(isnitf_meta(end).value);

isnitf_meta = checkIcords(icords, fid, isnitf_meta);

%NICOM
%Depending on its value there will be ICOM fields (ICOM1 through ICOMn).
%If NICOM is not zero, add the comment fields to the meta data struct
%and insert their values.

fields = {'NICOM', 'NumberOfImageComments', 1};
isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);

nicom = sscanf(isnitf_meta(end).value, '%f');
isnitf_meta = checkNicom(nicom, fid, isnitf_meta);

%Next field is Image Compression
fields = {'IC', 'ImageCompression', 2};
isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);

%Next field is COMRAT or Compression Rate Code
%If the IC field is not NC or NM the field will have a value.
ic = isnitf_meta(end).value;
if ~strcmp(ic, 'NC') && ~strcmp(ic, 'NM')
    fields = {'COMRAT', 'CompressionRateCode', 4};
    isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);
end

fields = {'NBANDS', 'NumberOfBands', 1};
isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);

nbands = sscanf(isnitf_meta(end).value, '%f');

%XBANDS
%If the NBANDS field is 0 XBANDS is the number of bands in a multi-spectral image.
if nbands == 0
    fields = {'XBANDS', 'NumberOfMultiSpectralBands', 5};
    isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);
    bands = sscanf(isnitf_meta(end).value, '%f');
else
    bands = nbands;
end

%Set up Band substructure

isnitf_meta(end + 1).name = 'Band Meta';
isnitf_meta(end).vname = 'BandMeta';
%The value will be a structure of band data

%The next seven fields occur for each band as indicated by BANDS
% Lengths:
% IREPBAND 2, ISUBCAT 6, IFC 1, IMFLT 3, NLUTS 1, NELUT 5 [omitted if NLUTS = 0]
%   LUTD contains data for the mth LUT of the nnth band

nitf_metaBand(bands).value = '';

for currentBand = 1: bands

    isBandnitf_meta = struct([]);

    nitf_metaBand(currentBand).name = sprintf('Band%03d', currentBand);
    nitf_metaBand(currentBand).vname = [nitf_metaBand(currentBand).name 'Meta'];
    nitf_metaBand(currentBand).value = '';

    fields = {'IREPBAND%02d', 'BandRepresentation%02d', 2
              'ISUBCAT%02d', 'BandSubcategory%02d', 6
              'IFC%02d', 'BandImageFilterCondition%02d', 1
              'IMFLT%02d', 'BandImageFilterCode%02d', 3
              'NLUTS%02d', 'BandNumberOfLUTS%02d', 1};
              
    isBandnitf_meta = nitfReadMetaMulti(isBandnitf_meta, fields, fid, currentBand);
    numluts = sscanf(isBandnitf_meta(end).value, '%f');

    if numluts ~= 0
        %nnth Band Number of LUT Entries
        
        fields = {'NELUT%02d', 'BandNumberOfLUTEntries%02d', 5};
        isBandnitf_meta = nitfReadMetaMulti(isBandnitf_meta, fields, fid, currentBand);

        numlutentries = sscanf(isBandnitf_meta(end).value', '%f');

        %The value will be a struct of LUT data
        for currentLut = 1 : numluts
            isBandnitf_meta(end + 1).name = sprintf('LUTData%1d', currentLut);
            isBandnitf_meta(end).vname = sprintf('LUTData%1d', currentLut);
            % Note: not converted to char.
            isBandnitf_meta(end).value = fread(fid, numlutentries, 'uint8');
        end
    end

    nitf_metaBand(currentBand).value = isBandnitf_meta;

end
isnitf_meta(end).value = nitf_metaBand;


fields = {'ISYNC', 'ImageSyncCode', 1
          'IMODE', 'ImageMode' 1
          'NBPR', 'NumberOfBlocksPerRow', 4};
isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);
NBPR = sscanf(isnitf_meta(end).value, '%f');

fields = {'NBPC', 'NumberOfBlocksPerColumn', 4};
isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);
NBPC = sscanf(isnitf_meta(end).value, '%f');

fields = {'NPPBH', 'NumberOfPixelsPerBlockHorizontal', 4
          'NPPBV', 'NumberOfPixelsPerBlockVertical', 4
          'NBPP', 'NumberOfBitsPerPixelPerBand', 2
          'IDLVL', 'DisplayLevel', 3
          'IALVL', 'ImageAttachmentLevel', 3
          'ILOC', 'ImageLocation', 10
          'IMAG', 'ImageMagnification', 4};
isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);

% The IMAG value should be converted to a number from the decimal string.
isnitf_meta(end).value = sscanf(isnitf_meta(end).value, '%f');

fields = {'UDIDL', 'UserDefinedImageDataLength', 5};
isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);

%If UDIDL is not zeros we'll have values for UDOFL and UDID
UDIDL = sscanf(isnitf_meta(end).value, '%f');
if UDIDL ~= 0

    fields = {'UDOFL', 'UserDefinedOverflow', 3
              'UDID', 'UserDefinedImageData', UDIDL - 3};
    isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);
    
end

fields = {'IXSHDL', 'ExtendedSubheaderDataLength', 5};
isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);

%If IXSHDL is not zeros we'll have values for IXSOFL and IXSHD
IXSHDL = sscanf(isnitf_meta(end).value, '%f');
if IXSHDL ~= 0

    fields = {'IXOFL', 'ExtendedSubheaderOverflow', 3
              'IXSHD', 'ExtendedSubheaderData', IXSHDL - 3};
    isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);
    
end

% If the image contains data masking, read those values.  (See
% MIL-STD-2500B Table A-3(A).
dataMaskTableLength = 0;
if (hasDataMaskTable(ic))
    
    fields = {'IMDATOFF',  'BlockedImageDataOffset',           1, 'int32'
              'BMRLNTH',   'BlockedMaskRecordLength',          1, 'uint16'};
    isnitf_meta = nitfReadMetaNumeric(isnitf_meta, fields, fid);
    BMRLNTH = isnitf_meta(end).value;
    
    fields = {'TMRLNTH',   'PadPixelMaskRecordLength',         1, 'uint16'};
    isnitf_meta = nitfReadMetaNumeric(isnitf_meta, fields, fid);
    TMRLNTH = isnitf_meta(end).value;
    
    fields = {'TPXCDLNTH', 'TransparentOutputPixelCodeLength', 1, 'uint16'};
    isnitf_meta = nitfReadMetaNumeric(isnitf_meta, fields, fid);
    TPXCDLNTH = isnitf_meta(end).value;

    dataMaskTableLength = dataMaskTableLength + 4  + 2 + 2 + 2;
    
    if (TPXCDLNTH ~= 0)
        
        if (TPXCDLNTH <= 8)
            fmt = 'uint8';
            dataMaskTableLength = dataMaskTableLength + 1;
        else
            fmt = 'uint16';
            dataMaskTableLength = dataMaskTableLength + 2;
        end
        
        fields = {'TPXCD', 'PadOutputPixelCode', 1, fmt};
        isnitf_meta = nitfReadMetaNumeric(isnitf_meta, fields, fid);
        
    end
    
    numBlocks = NBPR * NBPC * max(bands, nbands);
    
    if (BMRLNTH ~= 0)
        fields = {'BMRnBNDm', 'BlockNBandMOffset', numBlocks, 'uint32'};
        isnitf_meta = nitfReadMetaNumeric(isnitf_meta, fields, fid);
        dataMaskTableLength = dataMaskTableLength + 4 * numBlocks;
    end
    
    if (TMRLNTH ~= 0)
        fields = {'TMRnBNDm', 'PadPixelNBandMOffset', numBlocks, 'uint32'};
        isnitf_meta = nitfReadMetaNumeric(isnitf_meta, fields, fid);
        dataMaskTableLength = dataMaskTableLength + 4 * numBlocks;
    end
    
end

%Move the cursor through the image data
readforwardbytes = sscanf(dataLength, '%f') - dataMaskTableLength;
fseek(fid, readforwardbytes, 'cof');



function isnitf_meta = checkIcords(icords, fid, isnitf_meta)
if ~strcmp(icords, '')
    
    fields = {'IGEOLO', 'ImageGeographicLocation', 60};
    isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);

end



function isnitf_meta = checkNicom(nicom, fid, isnitf_meta)

% Parse the Image Comment fields in the image subheader
% The length of the ICOM field is 80.
for currentComment = 1:nicom
    
    %Pull the Image Comment
    fields = {'ICOM%1d', 'ImageComment%1d', 80};
    isnitf_meta = nitfReadMetaMulti(isnitf_meta, fields, fid, currentComment);
    
end



function tf = hasDataMaskTable(IC)

switch (IC)
case {'NM', 'M1', 'M3', 'M4', 'M5'}
    tf = true;
otherwise
    tf = false;
end
