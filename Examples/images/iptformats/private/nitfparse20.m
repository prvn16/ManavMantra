function nitf_meta = nitfparse20(fid)
%NITFPARSE20 Parse the fields in an NITF2.0 file.

%   Copyright 2007-2008 The MathWorks, Inc.

nitf_meta = struct([]);
fields = {'FHDR',    'FileTypeAndVersion',           9
          'CLEVEL',  'ComplianceLevel',              2
          'STYPE',   'SystemType',                   4
          'OSTAID',  'OriginatingStationID',        10
          'FDT',     'FileDateAndTime',             14
          'FTITLE',  'FileTitle',                   80
          'FSCLAS',  'FileSecurityClassification',   1
          'FSCODE',  'FileCodewords',               40
          'FSCTLH',  'FileControlAndHandling',      40
          'FSREL',   'FileReleasingInstructions',   40
          'FSCAUT',  'FileClassificationAuthority', 20
          'FSCTLN',  'FileSecurityControlNumber',   20 
          'FSDWNG',  'FileSecurityDowngrade',        6};
nitf_meta = nitfReadMeta(nitf_meta, fields, fid);

%FSDWNG is NITF_META(13) and the last item extracted in the loop above.  Depending
%on its value there will be an FSDEVT or File Downgrading Event field.
%If FSDWNG is "999998", add the FSDEVT field to the meta data struct
%and insert values.
fsdwng = nitf_meta(end).value;
nitf_meta = checkFDSWNG(fid, nitf_meta, fsdwng);

%Pull in the next several required fields
fields = {'FSCOP',  'MessageCopyNumber',       5
          'FSCPYS', 'MessageNumberOfCopies',   5
          'ENCRYP', 'Encryption',              1
          'ONAME',  'OriginatorsName',        27
          'OPHONE', 'OriginatorsPhoneNumber', 18
          'FL',     'FileLength',             12
          'HL',     'NITFFileHeaderLength',    6
          'NUMI',   'NumberOfImages',          3};
nitf_meta = nitfReadMeta(nitf_meta, fields, fid);

numi = sscanf(nitf_meta(end).value, '%f');
[nitf_meta, imLengths] = processtopimagesubheadermeta(numi, nitf_meta, fid);

%Next field gives the number of symbol (graphic) segments.
fields = {'NUMS', 'NumberOfSymbols', 3};
nitf_meta = nitfReadMeta(nitf_meta, fields, fid);

nums = sscanf(nitf_meta(end).value, '%f');
[nitf_meta, grLengths] = processtopgraphicsubheadermeta(nums, nitf_meta, fid);

%Next group is Labels
fields = {'NUML', 'NumberOfLabels', 3};
nitf_meta = nitfReadMeta(nitf_meta, fields, fid);

numl = sscanf(nitf_meta(end).value, '%f');
[nitf_meta, laLengths] = processtoplabelsubheadermeta(numl, nitf_meta, fid);

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
if XHDL > 0

    % Handle any Extended Header Data
    % Note: for our initial release we do not provide explicit support
    % for tagged record extensions.  All of the contents of the Extended
    % Header Data (XHD) field are extracted into a single element.
    fields = {'XHDL', 'ExtendedHeaderData', XHDL};
    nitf_meta = nitfReadMeta(nitf_meta, fields, fid);

end

%Call the image segment metadata parser for each image subheader

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

%Build the structure of LabelSubHeaders
if numl > 0
    nitf_meta = processLabelSubheaders(nitf_meta,numl ,fid, laLengths);
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



function nitf_meta = checkFDSWNG(fid, nitf_meta, fsdwng)
%TODO Factor this and other functions like it out!
fsdwng = sscanf(fsdwng, '%f');
if (isequal(fsdwng, 999998))
    fields = {'FSDEVT', 'FileDowngradingEvent', 40};
    nitf_meta = nitfReadMeta(nitf_meta, fields, fid);
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
    
    nitf_meta(end + 1).name = 'SymbolAndSubHeaderLengths';
    nitf_meta(end).vname = 'SymbolAndSymbolSubheaderLengths';

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



function [nitf_meta, laLengths] = processtoplabelsubheadermeta(numl, nitf_meta, fid)

laLengths(1).value = '';

if (numl > 0)
     
    % Preallocate the lengths structure.
    laLengths(numl).value = '';
   
    nitf_meta(end + 1).name = 'LabelAndSubHeaderLengths';
    nitf_meta(end).vname = 'LabelAndLabelSubheaderLengths';

    fields = {'LLSH%03d', 'LengthOfNthLabelSubheader', 4
              'LL%06d',   'LengthOfNthLabel',          3};
    
    for currentLabel = 1:numl
        
        % Setup.
        nitf_metaLSL(currentLabel).name = sprintf('Label%03d', currentLabel);
        nitf_metaLSL(currentLabel).vname = [nitf_metaLSL(currentLabel).name 'LabelAndSubheaderLengths'];

        % Parse the data.
        tempStruct = struct([]);
        tempStruct = nitfReadMetaMulti(tempStruct, fields, fid, currentLabel);
        nitf_metaLSL(currentLabel).value = tempStruct;
        
        % Update lengths with the value read.
        laLengths(currentLabel).value = tempStruct(2).value;
    
    end

    nitf_meta(end).value = nitf_metaLSL;
    
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



function nitf_meta = processImageSubheaders(nitf_meta, numi, fid, imLengths)
%Add the nth image subheader to the nitf_meta struct

nitf_meta(end + 1).name = 'ImageSubHeaders';
nitf_meta(end).vname = 'ImageSubheaderMetadata';

%Preallocate memory for ISnitf_meta
ISnitf_meta(numi).name = '';

for imageNumber = 1:numi
    ISnitf_meta(imageNumber).name = sprintf('IS%03d', imageNumber);
    ISnitf_meta(imageNumber).vname = sprintf('ImageSubheader%03d', imageNumber);
    ISnitf_meta(imageNumber).value = parseimagesubheader20( fid, imLengths(imageNumber).value);
end

nitf_meta(end).value = ISnitf_meta;



function nitf_meta = processGraphicSubheaders(nitf_meta, nums, fid, grLengths)
%Add the nth symbol subheader to the nitf_meta struct

nitf_meta(end + 1).name = 'SymbolSubHeaders';
nitf_meta(end).vname = 'SymbolSubheaderMetadata';

%Preallocate memory for ISnitf_meta
IGnitf_meta(nums).name = '';

for graphicNumber = 1:nums
    IGnitf_meta(graphicNumber).name = sprintf('IG%03d', graphicNumber);
    IGnitf_meta(graphicNumber).vname = sprintf('SymbolSubheader%03d', graphicNumber);
    IGnitf_meta(graphicNumber).value = parsegraphicsubheader20( fid, grLengths(graphicNumber).value);
end

nitf_meta(end).value = IGnitf_meta;



function nitf_meta = processLabelSubheaders(nitf_meta, numl, fid, laLengths)
%Add the nth text subheader to the nitf_meta struct

nitf_meta(end + 1).name = 'LabelSubHeaders';
nitf_meta(end).vname = 'LabelSubheaderMetadata';

%Preallocate memory for ILnitf_meta
ILnitf_meta(numl).value = '';

for labelNumber = 1:numl
    ILnitf_meta(labelNumber).name = sprintf('IL%03d', labelNumber);
    ILnitf_meta(labelNumber).vname = sprintf('LabelSubheader%03d', labelNumber);
    ILnitf_meta(labelNumber).value = parselabelsubheader20( fid, laLengths(labelNumber).value);
end

nitf_meta(end).value = ILnitf_meta;



function nitf_meta = processTextSubheaders(nitf_meta, numt, fid, teLengths)
%Add the nth text subheader to the nitf_meta struct

nitf_meta(end + 1).name = 'TextSubHeaders';
nitf_meta(end).vname = 'TextSubheaderMetadata';

%Preallocate memory for ITnitf_meta
ITnitf_meta(numt).value = '';

for textNumber = 1:numt
    ITnitf_meta(textNumber).name = sprintf('IT%03d', textNumber);
    ITnitf_meta(textNumber).vname = sprintf('TextSubheader%03d', textNumber);
    ITnitf_meta(textNumber).value = parsetextsubheader20( fid, teLengths(textNumber).value);
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
    DEnitf_meta(deNumber).value = parseDEsubheader20( fid, deLengths(deNumber).value);
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
