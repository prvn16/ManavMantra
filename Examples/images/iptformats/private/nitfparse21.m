function nitf_meta = nitfparse21(fid)
%NITFPARSE21 Parse the fields in an NITF2.1 file.

%   Copyright 2007-2008 The MathWorks, Inc.

nitf_meta = struct([]);
fields = {'FHDR',   'FileProfileNameAndVersion',         9
          'CLEVEL',  'ComplexityLevel',                  2
          'STYPE',   'StandardType',                     4
          'OSTAID',  'OriginatingStationID',            10
          'FDT',     'FileDateAndTime',                 14
          'FTITLE',  'FileTitle',                       80
          'FSCLAS',  'FileSecurityClassification',       1
          'FSCLSY',  'FileSecurityClassificationSystem', 2
          'FSCODE',  'FileCodewords',                   11
          'FSCTLH',  'FileControlAndHandling',           2
          'FSREL',   'FileReleasingInstructions',       20
          'FSDCTP',  'FileDeclassificationType',         2
          'FSDCDT',  'FileDeclassificationDate',         8
          'FSDCXM',  'FileDeclassificationExemption',    4
          'FSDG',    'FileDowngrade',                    1
          'FSDGT',   'FileDowngradeDate',                8
          'FSCLTX',  'FileClassificationText',          43
          'FSCATP',  'FileClassificationAuthorityType',  1
          'FSCAUT',  'FileClassificationAuthority',     40
          'FSCRSN',  'FileClassificationReason',         1
          'FSSRDT',  'FileSecuritySourceDate',           8
          'FSCTLN',  'FileSecurityControlNumber',       15
          'FSCOP',   'FileCopyNumber',                   5
          'FSCPYS',  'FileNumberOfCopies',               5
          'ENCRYP',  'Encryption',                       1
          'FBKGC',   'FileBackgroundColor',              3
          'ONAME',   'OriginatorName',                  24
          'OPHONE',  'OriginatorPhoneNumber',           18
          'FL',      'FileLength',                      12
          'HL',      'NITFFileHeaderLength',             6
          'NUMI',    'NumberOfImages',                   3};
nitf_meta = nitfReadMeta(nitf_meta, fields, fid);

numi = sscanf(nitf_meta(end).value, '%f');
[nitf_meta, imLengths] = processtopimagesubheadermeta(numi, nitf_meta, fid);

%Next field gives the number of graphics segments.
fields = {'NUMS', 'NumberOfGraphics', 3};
nitf_meta = nitfReadMeta(nitf_meta, fields, fid);

nums = sscanf(nitf_meta(end).value, '%f');
[nitf_meta, grLengths] = processtopgraphicsubheadermeta(nums, nitf_meta, fid);

%Next field is reserved for future use but it is a required field
fields = {'NUMX', 'ReservedForFutureUse', 3};
nitf_meta = nitfReadMeta(nitf_meta, fields, fid);

%Next group is text files
fields = {'NUMT', 'NumberOfTextFiles', 3};
nitf_meta = nitfReadMeta(nitf_meta, fields, fid);

numt = sscanf(nitf_meta(end).value, '%f');
[nitf_meta, teLengths] = processtoptextsubheadermeta(numt, nitf_meta, fid);

%Next group is Data Extension Segments
fields = {'NUMDES', 'NumberOfDataExtensionSegments', 3};
nitf_meta = nitfReadMeta(nitf_meta, fields, fid);

numdes = sscanf(nitf_meta(end).value, '%f');
[nitf_meta, deLengths] = processtopdesubheadermeta(numdes, nitf_meta, fid);

%Next group is Reserved Extension Segments
fields = {'NUMRES', 'NumberOfReservedDataExtensionSegments', 3};
nitf_meta = nitfReadMeta(nitf_meta, fields, fid);

numres = sscanf(nitf_meta(end).value, '%f');
[nitf_meta, reLengths, reHeaderLengths] = processtopresubheadermeta(numres, nitf_meta, fid);

%Next group is User Define Header Segments which contain tagged record extensions.
%Get the Header Data Length
fields = {'UDHDL', 'UserDefinedHeaderDataLength', 5};
nitf_meta = nitfReadMeta(nitf_meta, fields, fid);

UDHDL = sscanf(nitf_meta(end).value, '%f');
nitf_meta = processtopudsubheadermeta(UDHDL, nitf_meta, fid);

%Next group is Extended Header Segments which contain tagged record extensions.
%Get the Header Data Length
fields = {'XHDL', 'ExtendedHeaderDataLength', 5};
nitf_meta = nitfReadMeta(nitf_meta, fields, fid);

XHDL = sscanf(nitf_meta(end).value, '%f');
nitf_meta = processtopxsubheadermeta(XHDL, nitf_meta, fid);

%Call the image segment metadata parser for each image subheader

% We want the image subheader(s) to be drilllable from the structure
% editor.  Image subheader data will not be visible from command line
% feedback without explicitly accessing the structure.

%First, we want the nitf_meta struct to have a ImageSubHeader field.  This
%will have the total offset of the subheader(s), and the value will be
%a struct which contains a list of image subheaders.  Each subheader in
%the list is displayed table form when the user clicks on the struct
%value.

%Build the structure of ImageSubHeaders
if numi > 0
    nitf_meta = processImageSubheaders(nitf_meta,numi,fid, imLengths);
end

%Build the structure of SymbolSubHeaders
if nums > 0
    nitf_meta = processGraphicSubheaders(nitf_meta,nums ,fid, grLengths);
end

%Build the structure of TextSubHeaders
if numt > 0
    nitf_meta = processTextSubheaders(nitf_meta,numt ,fid, teLengths);
end

%Build the structure of DataExtensionSubHeaders
if numdes > 0
    nitf_meta = processDESubheaders(nitf_meta,numdes ,fid, deLengths);
end

%Build the structure of ReservedExtensionSubHeaders
if numres > 0
    nitf_meta = processRESubheaders(nitf_meta,numres ,fid, reLengths, reHeaderLengths);
end



function [nitf_meta, imLengths] = processtopimagesubheadermeta(numi, nitf_meta, fid)
%Add the nth image subheader information to the nitf_meta struct
%This struct contains the image subheader length and image length
%for all the images in the file
imLengths(1).value = '';

if (numi > 0)
    
    % Preallocate the lengths structure.
    imLengths(numi).value = '';
    
    nitf_meta(end + 1).name = 'ImageAndSubHeaderLengths';
    nitf_meta(end).vname = 'ImageAndImageSubheaderLengths';

    fields = {'LISH%03d', 'LengthOfNthImageSubheader',  6
              'LI%010d',  'LengthOfNthImage',          10};
    
    for currentImage = 1:numi

        % Setup.
        nitf_metaISL(currentImage).name = sprintf('Image%03d', currentImage);
        nitf_metaISL(currentImage).vname = [nitf_metaISL(currentImage).name 'ImageAndSubheaderLengths'];

        % Parse the data.
        tempStruct = struct([]);
        tempStruct = nitfReadMetaMulti(tempStruct, fields, fid, currentImage);
        nitf_metaISL(currentImage).value = tempStruct;
        
        % Update lengths with the value read.
        imLengths(currentImage).value = tempStruct(2).value;
        
    end

    nitf_meta(end).value = nitf_metaISL;
    
end



function [nitf_meta, grLengths] = processtopgraphicsubheadermeta(nums,nitf_meta, fid)

grLengths(1).value = '';

if (nums > 0)
    
    % Preallocate the lengths structure.
    grLengths(nums).value = '';
    
    nitf_meta(end + 1).name = 'GraphicAndSubHeaderLengths';
    nitf_meta(end).vname = 'GraphicAndGraphicSubheaderLengths';

    fields = {'LSSH%03d', 'LengthOfNthGraphicSubheader', 4
              'LS%06d',   'LengthOfNthGraphic',          6};
    
    for currentGraphic = 1:nums
        
        % Setup.
        nitf_metaGSL(currentGraphic).name = sprintf('Graphic%03d', currentGraphic);
        nitf_metaGSL(currentGraphic).vname = [nitf_metaGSL(currentGraphic).name 'GraphicAndSubheaderLengths'];

        % Parse the data.
        tempStruct = struct([]);
        tempStruct = nitfReadMetaMulti(tempStruct, fields, fid, currentGraphic);
        nitf_metaGSL(currentGraphic).value = tempStruct;
        
        % Update lengths with the value read.
        grLengths(currentGraphic).value = tempStruct(2).value;
        
    end

    nitf_meta(end).value = nitf_metaGSL;
    
end



function [nitf_meta, teLengths] = processtoptextsubheadermeta(numt, nitf_meta, fid)

teLengths(1).value = '';

if (numt > 0)
     
    % Preallocate the lengths structure.
    teLengths(numt).value = '';
   
    nitf_meta(end + 1).name = 'TextAndSubHeaderLengths';
    nitf_meta(end).vname = 'TextAndTextSubheaderLengths';

    fields = {'LTSH%03d', 'LengthOfNthTextSubheader', 4
              'LT%03d',   'LengthOfNthText',          5};
    
    for currentText = 1:numt
        
        % Setup.
        nitf_metaLTL(currentText).name = sprintf('Text%03d', currentText);
        nitf_metaLTL(currentText).vname = [nitf_metaLTL(currentText).name 'TextAndSubheaderLengths'];

        % Parse the data.
        tempStruct = struct([]);
        tempStruct = nitfReadMetaMulti(tempStruct, fields, fid, currentText);
        nitf_metaLTL(currentText).value = tempStruct;
        
        % Update lengths with the value read.
        teLengths(currentText).value = tempStruct(2).value;
    
    end

    nitf_meta(end).value = nitf_metaLTL;

end



function [nitf_meta, deLengths] = processtopdesubheadermeta(numdes, nitf_meta, fid)

deLengths(1).value = '';

if (numdes > 0)
    
    % Preallocate the lengths structure.
    deLengths(numdes).value = '';
   
    nitf_meta(end + 1).name = 'DataExtensionsAndSubHeaderLengths';
    nitf_meta(end).vname = 'DataExtensionAndDataExtensionSubheaderLengths';

    fields = {'LDSH%03d', 'LengthOfNthDataExtensionSubheader', 4
              'LD%03d',   'LengthOfNthDataExtension',          9};
    
    for currentDES = 1:numdes
        
        % Setup.
        nitf_metaDES(currentDES).name = sprintf('DataExtension%03d', currentDES);
        nitf_metaDES(currentDES).vname = [nitf_metaDES(currentDES).name 'DataExtensionAndSubheaderLengths'];

        % Parse the data.
        tempStruct = struct([]);
        tempStruct = nitfReadMetaMulti(tempStruct, fields, fid, currentDES);
        nitf_metaDES(currentDES).value = tempStruct;
        
        % Update lengths with the value read.
        deLengths(currentDES).value = tempStruct(2).value;
    
    end

    nitf_meta(end).value = nitf_metaDES;

end



function [nitf_meta, reLengths, reHeaderLengths] = processtopresubheadermeta(numres, nitf_meta, fid)

reLengths(1).value = '';
reHeaderLengths(1).value = '';

if (numres > 0)
    
    % Preallocate the lengths structure.
    reLengths(numres).value = '';
    reHeaderLengths(numres).value = '';
    
    nitf_meta(end + 1).name = 'ReservedExtensionsAndSubHeaderLengths';
    nitf_meta(end).vname = 'ReservedExtensionAndReservedExtensionSubheaderLengths';

    fields = {'LRSH%03d', 'LengthOfNthReservedExtensionSegmentSubheader', 4
              'LR%03d',   'LengthOfNthReservedExtensionSegmentData',      7};
    
    for currentRES = 1:numres

        % Setup.
        nitf_metaRES(currentRES).name = sprintf('ReservedExtension%03d', currentRES);
        nitf_metaRES(currentRES).vname = [nitf_metaRES(currentRES).name 'ReservedExtensionAndSubheaderLengths'];

        % Parse the data.
        tempStruct = struct([]);
        tempStruct = nitfReadMetaMulti(tempStruct, fields, fid, currentRES);
        nitf_metaRES(currentRES).value = tempStruct;

        % Update lengths with the value read.
        reHeaderLengths(currentRES).value = tempStruct(1).value;
        reLengths(currentRES).value = tempStruct(2).value;
    
    end

    nitf_meta(end).value = nitf_metaRES;
    
end



function nitf_meta = processtopudsubheadermeta(UDHDL, nitf_meta, fid)

if (UDHDL > 0)

    fields = {'UDHOFL', 'UserDefinedHeaderOverflow',      3
              'UDHDL',  'UserDefinedHeaderData',  UDHDL - 3};
    nitf_meta = nitfReadMeta(nitf_meta, fields, fid);
    
end



function nitf_meta = processtopxsubheadermeta(XHDL, nitf_meta, fid)

if (XHDL > 0)
    
    fields = {'XHDLOFL', 'UserHeaderDataOverflow', 3
              'XHDL', 'ExtendedHeaderData', XHDL - 3};
    nitf_meta = nitfReadMeta(nitf_meta, fields, fid);
    
end



function nitf_meta = processImageSubheaders(nitf_meta, numi, fid, imLengths)
%Add the nth image subheader to the nitf_meta struct

nitf_meta(end + 1).name = 'ImageSubHeaders';
nitf_meta(end).vname = 'ImageSubheaderMetadata';

%Preallocate memory for ISnitf_meta
ISnitf_meta(numi).name = '';

for imageNumber = 1:numi
    ISnitf_meta(imageNumber).name = sprintf('IS%03d', imageNumber);
    ISnitf_meta(imageNumber).vname = sprintf('ImageSubheader%03d', imageNumber);
    ISnitf_meta(imageNumber).value = parseimagesubheader( fid, imLengths(imageNumber).value);
end

nitf_meta(end).value = ISnitf_meta;



function nitf_meta = processGraphicSubheaders(nitf_meta, nums, fid, grLengths)
%Add the nth graphic subheader to the nitf_meta struct

nitf_meta(end + 1).name = 'GraphicSubHeaders';
nitf_meta(end).vname = 'GraphicSubheaderMetadata';

%Preallocate memory for ISnitf_meta
IGnitf_meta(nums).name = '';

for graphicNumber = 1:nums
    IGnitf_meta(graphicNumber).name = sprintf('IG%03d', graphicNumber);
    IGnitf_meta(graphicNumber).vname = sprintf('GraphicSubheader%03d', graphicNumber);
    IGnitf_meta(graphicNumber).value = parsegraphicsubheader( fid, grLengths(graphicNumber).value);
end

nitf_meta(end).value = IGnitf_meta;



function nitf_meta = processTextSubheaders(nitf_meta, numt, fid, teLengths)
%Add the nth text subheader to the nitf_meta struct

nitf_meta(end + 1).name = 'TextSubHeaders';
nitf_meta(end).vname = 'TextSubheaderMetadata';

%Preallocate memory for ITnitf_meta
ITnitf_meta(numt).value = '';

for textNumber = 1:numt
    ITnitf_meta(textNumber).name = sprintf('IT%03d', textNumber);
    ITnitf_meta(textNumber).vname = sprintf('TextSubheader%03d', textNumber);
    ITnitf_meta(textNumber).value = parsetextsubheader( fid, teLengths(textNumber).value);
end

nitf_meta(end).value = ITnitf_meta;



function nitf_meta = processDESubheaders(nitf_meta, numdes, fid, deLengths)
%Add the nth data extension subheader to the nitf_meta struct

nitf_meta(end + 1).name = 'DataExtensionSubHeaders';
nitf_meta(end).vname = 'DataExtensionSubheaderMetadata';

%Preallocate memory for ITnitf_meta
DEnitf_meta(numdes).value = '';

for deNumber = 1:numdes
    DEnitf_meta(deNumber).name = sprintf('DE%03d', deNumber);
    DEnitf_meta(deNumber).vname = sprintf('DataExtensionSubheader%03d', deNumber);
    DEnitf_meta(deNumber).value = parseDEsubheader( fid, deLengths(deNumber).value);
end

nitf_meta(end).value = DEnitf_meta;



function nitf_meta = processRESubheaders(nitf_meta, numres, fid, reLengths, reHeaderLengths)
%Add the nth reserved extension header to the nitf_meta struct

nitf_meta(end + 1).name = 'ReservedExtensionSubHeaders';
nitf_meta(end).vname = 'ReservedExtensionSubheaderMetadata';

%Preallocate memory for ITnitf_meta..How to do this?
REnitf_meta(numres).value = '';

for reNumber = 1:numres
    REnitf_meta(reNumber).name = sprintf('RE%03d', reNumber);
    REnitf_meta(reNumber).vname = sprintf('ReserveExtensionSubheader%03d', reNumber);
    REnitf_meta(reNumber).value = parseREsubheader20( fid, reLengths(reNumber).value, reHeaderLengths(reNumber).value);
end

nitf_meta(end).value = REnitf_meta;
