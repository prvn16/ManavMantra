function isnitf_meta = parseimagesubheader20( fid, dataLength )
%PARSEIMAGESUBHEADER Parse the Image subheaders in an NITF file.
%   ISNITF_META = PARSEIMAGESUBHEADER
%   Parse the Image Segment Subheader for an NITF 2.0 file.

%   Copyright 2007-2008 The MathWorks, Inc.

% TODO: complete refactorization around conditionals

%  Initialize the image subheader structure
isnitf_meta = struct([]);
fields = {'IM',      'FilePartType',                   2
          'IID',     'ImageID',                       10
          'IDATIM',  'ImageDateAndTime',              14
          'TGTID',   'TargetID',                      17
          'ITITLE',  'ImageTitle',                    80
          'ISCLAS',  'ImageSecurityClassification',    1
          'ISCODE',  'ImageCodewords',                40
          'ISCTLH',  'ImageControlAndHandling',       40
          'ISREL',   'ImageReleasingInstructions',    40
          'ISCAUT',  'ImageClassificationAuthority',  20
          'ISCTLN',  'ImageSecurityControlNumber',    20
          'ISDWNG',  'ImageSecurityDowngrade',         6};
isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);

%ISDWNG is the last item extracted in the loop above.  Depending
%on its value there will be an ISDEVT or Image Downgrading Event field.
%If ISDWNG is "999998, add the ISDEVT field to the meta data struct
%and insert values.
isdwng = sscanf(isnitf_meta(end).value, '%f');

%File downgrade event is conditional on fsdwng
isnitf_meta = checkISDWNG(fid, isnitf_meta, isdwng);

fields = {'ENCRYP', 'Encryption', 1
          'ISORCE', 'ImageSource', 42
          'NROWS', 'NumberOfSignificantRowsInImage', 8
          'NCOLS', 'NumberOfSignificantColumnsInImage', 8
          'PVTYPE', 'PixelValueType', 3
          'IREP', 'ImageRepresentation', 8
          'ICAT', 'ImageCategory', 8
          'ABPP', 'ActualBitsPerPixelPerBand', 2
          'PJUST', 'PixelJustification', 1
          'ICORDS', 'ImageCoordinateSystem', 1};
isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);

%ICORDS Depending on its value there will be an IGEOLO or Image Geographic Location field.
%If ICORDS is not a space, add the IGEOLO field to the meta data struct
%and insert values.
icords = isnitf_meta(end).value;
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

bands = sscanf(isnitf_meta(end).value, '%f');

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
          'NBPR', 'NumberOfBlocksPerRow', 4
          'NBPC', 'NumberOfBlocksPerColumn', 4
          'NPPBH', 'NumberOfPixelsPerBlockHorizontal', 4
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

%Move the cursor through the image data
readforwardbytes = sscanf(dataLength, '%f');
fseek(fid, readforwardbytes, 'cof');



function isnitf_meta = checkISDWNG(fid, isnitf_meta, fsdwng)

if  fsdwng == 999998

    fields = {'ISDEVT', 'ImageDowngradingEvent', 40};
    isnitf_meta = nitfReadMeta(isnitf_meta, fields, fid);
    
end



function isnitf_meta = checkIcords(icords, fid, isnitf_meta)

if ~strcmp(icords, 'N')
    
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
