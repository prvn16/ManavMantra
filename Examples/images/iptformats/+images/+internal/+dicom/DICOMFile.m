classdef DICOMFile < handle
    % DICOMFile   Minimally processed/parsed DICOM file.
    % OBJ = DICOMFile(FILENAME) parses the DICOM file with character or
    % string name FILENAME, which can be the full path to a file, a partial
    % path, or a file on the path.
    %
    % DICOMFile Properties:
    %    AttributeNames - Name of the top-level attributes in the DICOM file
    %    Dictionary - Full path to the DICOM data dictionary in use
    %    Filename - Full path to the file
    % 
    % DICOMFile Methods:
    %    getAttribute - Get a parsed attribute by group and element pair
    %    getAttributeByName - Get a parsed attribute by name
    %    setAttribute - Set an attribute using group and element pair
    %    setAttributeByname - Set an attribute by name
    %    serializeToBytes - Convert object to bytes that can be saved as a DICOM file

    % NOTE: This class will likely change in a future release.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (SetAccess = private, GetAccess = public)
        Filename
        AttributeNames
        Dictionary
    end
    
    
    properties (Access = private)
        CachedAttributeNames
        CachedAttributeValues
        RawAttrs
    end
    
    
    properties (Dependent = true, Hidden = true)
        TransferSyntaxUID
        Modality
        MediaStorageSOPClassUID  % (0002,0002)
        SOPClassUID  % (0008,0016)
        SOPInstanceUID  % (0008,0018)
        FileMetaInformationVersion
        MediaStorageSOPInstanceUID
        ImplementationClassUID
        ImplementationVersionName
        SamplesPerPixel
        PhotometricInterpretation
        Rows
        Columns
        BitsAllocated
        BitsStored
        HighBit
        PixelRepresentation
        PixelData
        SmallestImagePixelValue
        LargestImagePixelValue
    end
    
    
    methods
        function obj = DICOMFile(filename)
            % DICOMFile constructor
            
            if iscellstr(filename) || isstring(filename)
                validateattributes(filename, ...
                    {'cell','cellstr','char','string'}, ...
                    {'scalartext'}, mfilename,'FILENAME',1);
            end
            
            obj.Dictionary = dicomdict('get_current');
            obj.Filename = matlab.images.internal.stringToChar(filename);
            
            % Get details about the file to read.
            verifyIsDICOM = true;
            fileDetails = images.internal.dicom.getFileDetails(filename, verifyIsDICOM);
            
            % Ensure the file is actually DICOM.
            if (~fileDetails.isdicom)
                error(message('images:dicominfo:notDICOM'))
            end
            
            % Parse the DICOM file.
            useVRHeuristic = true;
            readPixelData = false;
            obj.RawAttrs = images.internal.dicom.dicomparse(fileDetails.name, ...
                fileDetails.bytes, ...
                getMachineEndian(), ...
                readPixelData, ...
                obj.Dictionary, ...
                useVRHeuristic);
        end
            
        function attr = getAttribute(obj, group, element)
            % Get a parsed attribute by group and element pair
            
            numericGroup = convertToNumeric(group);
            numericElement = convertToNumeric(element);

            cacheFieldname = sprintf('c%d_%d', numericGroup, numericElement);
            
            if isfield(obj.CachedAttributeValues, cacheFieldname)
                attr = obj.CachedAttributeValues.(cacheFieldname);
            else
                unprocessedAttr = obj.getRawAttribute(numericGroup, numericElement);
                
                if numel(unprocessedAttr) > 1
                    warning(message('images:DICOMFile:duplicateAttributes'))
                end
                
                if (~isempty(unprocessedAttr))
                    topLevel = true;
                    attr = obj.convertAttribute(unprocessedAttr(1), topLevel);
                    obj.CachedAttributeValues.(cacheFieldname) = attr;
                else
                    attr = [];
                end
            end
        end
        
        function attr = getAttributeByName(obj, name)
            % Get a parsed attribute by name
            
            [numericGroup, numericElement] = images.internal.dicom.lookupActions(name, obj.Dictionary);
            
            if (isempty(numericGroup))
                attr = [];
                return
            end
            
            attr = obj.getAttribute(numericGroup, numericElement);
        end
        
%{
        function setAttributeByName(obj, name, newValue)
            % Set an attribute by name
            
            [numericGroup, numericElement] = images.internal.dicom.lookupActions(name, obj.Dictionary);
            assert(~isempty(numericGroup)) %TODO: Is it okay for this to assert?
            
            obj.setAttribute(numericGroup, numericElement, newValue)
        end
        
        function setAttribute(obj, group, element, newValue)
            % Set an attribute using group and element pair
            
            numericGroup = convertToNumeric(group);
            numericElement = convertToNumeric(element);

            % Look for the attribute's raw data.
            rawAttrIndex = obj.findRawAttrIndex(numericGroup, numericElement);
            
            if (~isempty(rawAttrIndex))
                obj.updateRawAttribute(rawAttrIndex, newValue)
            else
                obj.addRawAttribute(numericGroup, numericElement, newValue)
            end
            
            % Update the cache.
            name = sprintf('c%d_%d', group, element);
            obj.CachedAttributeValues.(name) = newValue;
        end
%}
        
        function attrNames = get.AttributeNames(obj)
            if (~isempty(obj.CachedAttributeNames))
                attrNames = obj.CachedAttributeNames;
                return
            end
            
            % Get the attribute names.
            totalAttrs = numel(obj.RawAttrs);
            attrNames = cell(totalAttrs,1);
            
            for currentAttr = 1:totalAttrs
                attrNames{currentAttr} = ...
                    images.internal.dicom.lookupActions(obj.RawAttrs(currentAttr).Group, ...
                    obj.RawAttrs(currentAttr).Element, ...
                    obj.Dictionary);
                
                % Empty attributes indicate that a public/retired attribute was
                % not found in the data dictionary.  This used to be an error
                % condition, but is easily resolved by providing a special
                % attribute name.
                if (isempty(attrNames{currentAttr}))
                    attrNames{currentAttr} = sprintf('Unknown_%04X_%04X', ...
                        obj.RawAttrs(currentAttr).Group, ...
                        obj.RawAttrs(currentAttr).Element);
                end
            end
            
            obj.CachedAttributeNames = attrNames;
        end
        
        function byteStream = serializeToBytes(obj, txfr)
            % Convert object to bytes that can be saved as a DICOM file
            
            uidDetails = images.dicom.decodeUID(txfr);
            [swapFile, swapMeta, swapPixel] = images.internal.dicom.determineSwap(txfr, uidDetails);
            
            byteStream = [];
            
            for idx = 1:numel(obj.RawAttrs)
                thisAttr = obj.RawAttrs(idx);
                
                % Skip group length attributes. This is legal to do.
                if (thisAttr.Element == 0)
                    continue;
                end
                
                thisSerializedAttr = serializeOneAttribute(thisAttr, txfr, uidDetails, swapFile, swapMeta, swapPixel);
                byteStream = addToByteStream(byteStream, thisSerializedAttr);
            end
        end
    end
    
    
    methods  % Attribute getters/setters
        function attr = get.TransferSyntaxUID(obj)
            attr = obj.getAttribute(2, 16);  % (0002,0010)
        end
        
        function attr = get.Modality(obj)
            attr = obj.getAttribute(8, 96);  % (0008,0060)
        end
        
        function attr = get.MediaStorageSOPClassUID(obj)
            attr = obj.getAttribute(2, 2);  % (0002,0002)
        end
        
        function attr = get.SOPClassUID(obj)
            attr = obj.getAttribute(8, 22);  % (0008,0016)
        end
        
        function attr = get.SOPInstanceUID(obj)
            attr = obj.getAttribute(8, 24);  % (0008,0018)
        end
        
        function attr = get.FileMetaInformationVersion(obj)
            attr = obj.getAttribute(2, 1);  % (0002,0001)
        end
        
        function attr = get.MediaStorageSOPInstanceUID(obj)
            attr = obj.getAttribute(2, 3);  % (0002,0003)
        end
        
        function attr = get.ImplementationClassUID(obj)
            attr = obj.getAttribute(2, 18);  % (0002,0012)
        end
        
        function attr = get.ImplementationVersionName(obj)
            attr = obj.getAttribute(2, 19);  % (0002,0013)
        end
        
        function attr = get.SamplesPerPixel(obj)
            attr = obj.getAttribute(40, 2);  % (0028,0002)
        end
        
        function attr = get.PhotometricInterpretation(obj)
            attr = obj.getAttribute(40, 4);  % (0028,0004)
        end
        
        function attr = get.Rows(obj)
            attr = obj.getAttribute(40, 16);  % (0028,0010)
        end
        
        function attr = get.Columns(obj)
            attr = obj.getAttribute(40, 17);  % (0028,0011)
        end
        
        function attr = get.BitsAllocated(obj)
            attr = obj.getAttribute(40, 256);  % (0028,0100)
        end
        
        function attr = get.BitsStored(obj)
            attr = obj.getAttribute(40, 257);  % (0028,0101)
        end
        
        function attr = get.HighBit(obj)
            attr = obj.getAttribute(40, 258);  % (0028,0102)
        end
        
        function attr = get.PixelRepresentation(obj)
            attr = obj.getAttribute(40, 259);  % (0028,0103)
        end
        
        function attr = get.SmallestImagePixelValue(obj)
            attr = obj.getAttribute(40, 262);  % (0028,0106)
        end
        
        function attr = get.LargestImagePixelValue(obj)
            attr = obj.getAttribute(40, 263);  % (0028,0107)
        end
        
        function attr = get.PixelData(obj)
            attr = obj.getAttribute(32736, 16);  % (7FE0,0010)
        end
        
%{        
        function set.SOPInstanceUID(obj, value)
            obj.setAttribute(8, 24, value)  % (0008,0018)
        end
        
        function set.TransferSyntaxUID(obj, value)
            obj.setAttribute(2, 16, value)  % (0002,0010)
        end
        
        function set.Modality(obj, value)
            obj.setAttribute(8, 96, value)  % (0008,0060)
        end
        
        function set.MediaStorageSOPClassUID(obj, value)
            obj.setAttribute(2, 2, value)  % (0002,0002)
        end
        
        function set.SOPClassUID(obj, value)
            obj.setAttribute(8, 22, value)  % (0008,0016)
        end
        
        function set.FileMetaInformationVersion(obj, value)
            obj.setAttribute(2, 1, value)  % (0002,0001)
        end
        
        function set.MediaStorageSOPInstanceUID(obj, value)
            obj.setAttribute(2, 3, value)  % (0002,0003)
        end
        
        function set.ImplementationClassUID(obj, value)
            obj.setAttribute(2, 18, value)  % (0002,0012)
        end
        
        function set.ImplementationVersionName(obj, value)
            obj.setAttribute(2, 19, value)  % (0002,0013)
        end
        
        function set.SamplesPerPixel(obj, value)
            obj.setAttribute(40, 2, value)  % (0028,0002)
        end
        
        function set.PhotometricInterpretation(obj, value)
            obj.setAttribute(40, 4, value)  % (0028,0004)
        end
        
        function set.Rows(obj, value)
            obj.setAttribute(40, 16, value)  % (0028,0010)
        end
        
        function set.Columns(obj, value)
            obj.setAttribute(40, 17, value)  % (0028,0011)
        end
        
        function set.BitsAllocated(obj, value)
            obj.setAttribute(40, 256, value)  % (0028,0100)
        end
        
        function set.BitsStored(obj, value)
            obj.setAttribute(40, 257, value)  % (0028,0101)
        end
        
        function set.HighBit(obj, value)
            obj.setAttribute(40, 258, value)  % (0028,0102)
        end
        
        function set.PixelRepresentation(obj, value)
            obj.setAttribute(40, 259, value)  % (0028,0103)
        end
        
        function set.SmallestImagePixelValue(obj, value)
            obj.setAttribute(40, 262, value)  % (0028,0106)
        end
        
        function set.LargestImagePixelValue(obj, value)
            obj.setAttribute(40, 263, value)  % (0028,0107)
        end
        
        function set.PixelData(obj, value)
            obj.setAttribute(32736, 16, value)  % (7FE0,0010)
        end
%}
    end
    
    
    methods (Hidden = true)
        function TF = isfield(obj, name)
            TF = ~isempty(intersect(name, obj.AttributeNames));
        end
        
        function sortAttributes(obj)
            allElements = [obj.RawAttrs.Element];
            [~, idx] = sort(allElements);
            obj.RawAttrs = obj.RawAttrs(idx);
            
            allGroups = [obj.RawAttrs.Group];
            [~, idx] = sort(allGroups);
            obj.RawAttrs = obj.RawAttrs(idx);
        end
    end
   
    
    methods (Access = private)
        function unprocessedAttr = getRawAttribute(obj, numericGroup, numericElement)
            idx = ([obj.RawAttrs.Group] == numericGroup) & ([obj.RawAttrs.Element] == numericElement);
            unprocessedAttr = obj.RawAttrs(idx);
        end
        
        function attr = convertAttribute(obj, unprocessedAttr, topLevel)
            useDictionaryVR = false;
            metadata = struct([]);
            attr = obj.convertRawAttr(unprocessedAttr, useDictionaryVR, topLevel, metadata);
        end
                
        function [metadata,attrNames] = processMetadata(obj, unprocessedAttrs, useDictionaryVR)
            if (isempty(unprocessedAttrs))
                metadata = [];
                return
            end
            
            % Create a structure for the output and get the names of attributes.
            topLevel = false;
            [metadata, attrNames] = obj.createMetadataStruct(unprocessedAttrs, topLevel);
            
            % Fill the metadata structure, converting data along the way.
            for currentAttr = 1:numel(attrNames)
                this = unprocessedAttrs(currentAttr);
                metadata.(attrNames{currentAttr}) = obj.convertRawAttr(this, useDictionaryVR, topLevel, metadata);
            end
        end
        
        function [metadata, attrNames] = createMetadataStruct(obj, attrs, isTopLevel)
            % Get the attribute names.
            totalAttrs = numel(attrs);
            attrNames = cell(1, totalAttrs);
            
            for currentAttr = 1:totalAttrs
                attrNames{currentAttr} = ...
                    images.internal.dicom.lookupActions(attrs(currentAttr).Group, ...
                    attrs(currentAttr).Element, ...
                    obj.Dictionary);
                
                % Empty attributes indicate that a public/retired attribute was
                % not found in the data dictionary.  This used to be an error
                % condition, but is easily resolved by providing a special
                % attribute name.
                if (isempty(attrNames{currentAttr}))
                    attrNames{currentAttr} = sprintf('Unknown_%04X_%04X', ...
                        attrs(currentAttr).Group, ...
                        attrs(currentAttr).Element);
                end
            end
            
            % Remove duplicate attribute names.  Keep the last appearance of the attribute.
            [tmp, reorderIdx] = unique(attrNames);
            if (numel(tmp) ~= totalAttrs)
                warning(message('images:dicominfo:attrWithSameName'))
            end
            
            uniqueAttrNames = attrNames(sort(reorderIdx));
            uniqueTotalAttrs = numel(uniqueAttrNames);
            
            % Create a metadata structure to hold the parsed attributes.  Use a
            % cell array initializer, which has a populated section for IMFINFO
            % data and an unitialized section for the attributes from the DICOM
            % file.
            if (isTopLevel)
                structInitializer = cat(2, getImfinfoFields(), ...
                    cat(1, uniqueAttrNames, cell(1, uniqueTotalAttrs)));
            else
                structInitializer = cat(1, uniqueAttrNames, cell(1, uniqueTotalAttrs));
            end
            
            metadata = struct(structInitializer{:});
        end
        
        function processedAttr = convertRawAttr(obj, rawAttr, useDictionaryVR, topLevel, siblingMetadata)
            % Information about whether to swap is contained in the attribute.
            swap = needToSwap(rawAttr);
            
            if useDictionaryVR || isempty(rawAttr.VR)
                dictionaryVR = obj.findVRFromTag(rawAttr.Group, rawAttr.Element);
            end
            
            % Determine the correct output encoding.
            if (isempty(rawAttr.VR))
                % Look up VR for implicit VR files.  Use 'UN' for unknown
                % tags.  (See PS 3.5 Sec. 6.2.2.)
                if (~isempty(dictionaryVR))
                    
                    % Some attributes have a conditional VR.  Pick the first.
                    rawAttr.VR = dictionaryVR;
                    if (numel(rawAttr.VR) > 2)
                        rawAttr.VR = rawAttr.VR(1:2);
                    end
                    
                else
                    rawAttr.VR = 'UN';
                end
            end
            
            % Convert raw data.  (See PS 3.5 Sec. 6.2 for full VR details.)
            switch (rawAttr.VR)
            case  {'AE','AS','CS','DA','DT','LO','LT','SH','ST','TM','UI','UT'}
                processedAttr = images.internal.dicom.deblankAndStripNulls(char(rawAttr.Data));

            case {'AT'}
                % For historical reasons don't transpose AT.
                processedAttr = images.internal.dicom.typecast(rawAttr.Data, 'uint16', swap);

            case {'DS', 'IS'}
                processedAttr = sscanf(char(rawAttr.Data), '%f\\');

            case {'FL', 'OF'}
                processedAttr = images.internal.dicom.typecast(rawAttr.Data, 'single', swap)';

            case 'FD'
                processedAttr = images.internal.dicom.typecast(rawAttr.Data, 'double', swap)';

            case 'OB'
                processedAttr = rawAttr.Data';

            case {'OW', 'US'}
                processedAttr = images.internal.dicom.typecast(rawAttr.Data, 'uint16', swap)';

            case 'PN'
                if topLevel
                    % Get SpecificCharacterSet from obj
                    processedAttr = images.internal.dicom.localizePN(rawAttr.Data, obj);
                else
                    % Get SpecificCharacterSet from sibling metadata currently being parsed.
                    processedAttr = images.internal.dicom.localizePN(rawAttr.Data, ...
                        siblingMetadata, obj.Dictionary);
                end

            case 'SL'
                processedAttr = images.internal.dicom.typecast(rawAttr.Data, 'int32', swap)';

            case 'SQ'
                processedAttr = obj.parseSequence(rawAttr.Data, useDictionaryVR);

            case 'SS'
                processedAttr = images.internal.dicom.typecast(rawAttr.Data, 'int16', swap)';

            case 'UL'
                processedAttr = images.internal.dicom.typecast(rawAttr.Data, 'uint32', swap)';

            case 'UN'
                % It's possible that the attribute contains a private sequence
                % with implicit VR; in which case the Data field contains the
                % parsed sequence.
                if (isstruct(rawAttr.Data))
                    processedAttr = obj.parseSequence(rawAttr.Data, useDictionaryVR);
                else
                    processedAttr = rawAttr.Data';
                end

            otherwise
                % PS 3.5-1999 Sec. 6.2 indicates that all unknown VRs can be
                % interpretted as UN.
                processedAttr = rawAttr.Data';
            end
            
            % Change empty arrays to 0-by-0.
            if isempty(processedAttr)
                processedAttr = reshape(processedAttr, [0 0]);
            end
        end

        function [vr, name] = findVRFromTag(obj, group, element)
            % Look up the attribute.
            attr = images.internal.dicom.dicomlookup_helper(group, element, obj.Dictionary);
            
            % Get the vr.
            if (~isempty(attr))
                vr = attr.VR;
                name = attr.Name;
            else
                % Private creator attributes should be treated as CS.
                if ((rem(group, 2) == 1) && (element == 0))
                    vr = 'UL';
                elseif ((rem(group, 2) == 1) && (element < 256))
                    vr = 'CS';
                else
                    vr = 'UN';
                end
                
                name = '';
            end
        end
        
        function processedStruct = parseSequence(obj, attrs, useDictionaryVR)
            numItems = countItems(attrs);
            itemNames = getItemNames(numItems);
            
            % Initialize the structure to contain this structure.
            structInitializer = cat(1, itemNames, cell(1, numItems));
            processedStruct = struct(structInitializer{:});
            
            % Process each item (but not delimiters).
            item = 0;
            for idx = 1:numel(attrs)
                
                this = attrs(idx);
                if (~isDelimiter(this))
                    item = item + 1;
                    processedStruct.(itemNames{item}) = obj.processMetadata(this.Data, useDictionaryVR);
                end
                
            end
        end
        
        function index = findRawAttrIndex(obj, numericGroup, numericElement)
            % 
            
            mask = ([obj.RawAttrs.Group] == numericGroup) & ...
                ([obj.RawAttrs.Element] == numericElement);
            
            index = find(mask);
        end
        
%{
        function addRawAttribute(obj, group, element, value)
            obj.RawAttrs(end+1).Group = group;
            obj.RawAttrs(end).Element = element;
            
            dictionaryAttr = images.internal.dicom.dicomlookup_helper(group, element, obj.Dictionary);
            if (isempty(dictionaryAttr))
                obj.RawAttrs(end).VR = 'UN';
            else
                obj.RawAttrs(end).VR = dictionaryAttr.VR;
            end
            
            obj.RawAttrs(end).Data = convertToUint8(value, group, element, obj.RawAttrs(end).VR);
            obj.RawAttrs(end).Length = numel(obj.RawAttrs(end).Data);
        end

        function updateRawAttribute(obj, rawAttrIndex, newValue)
            theRawAttr = obj.RawAttrs(rawAttrIndex);
            
            obj.RawAttrs(rawAttrIndex).Data = convertToUint8(newValue, ...
                theRawAttr.Group, theRawAttr.Element, theRawAttr.VR);
            obj.RawAttrs(rawAttrIndex).Length = numel(obj.RawAttrs(rawAttrIndex).Data);
        end
%}
    end
end


function byteOrder = getMachineEndian

persistent endian

if (~isempty(endian))
  byteOrder = endian;
  return
end

[~, ~, endian] = computer;
byteOrder = endian;

end


function tf = needToSwap(currentAttr)

switch (getMachineEndian())
case 'L'
    if (currentAttr.IsLittleEndian)
        tf = false;
    else
        tf = true;
    end
    
case 'B'
    if (currentAttr.IsLittleEndian)
        tf = true;
    else
        tf = false;
    end
  
otherwise
    error(message('images:dicominfo:unknownEndian', getMachineEndian))

end

end


function count = countItems(attrs)

if (isempty(attrs))
    count = 0;
else
    % Find the items (FFFE,E000) in the array of attributes (all of
    % which are item tags or delimiters; no normal attributes
    % appear in attrs here). 
    idx = find(([attrs(:).Group] == 65534) & ...
               ([attrs(:).Element] == 57344));
    count = numel(idx);
end
end
    

function tf = isDelimiter(attr)

% True if (FFFE,E00D) or (FFFE,E0DD).
tf = (attr.Group == 65534) && ...
     ((attr.Element == 57357) || (attr.Element == 57565));
end


function itemNames = getItemNames(numberOfItems)

% Create a cell array of item names, which can be quickly used.
persistent namesCell
if (isempty(namesCell))
    namesCell = generateItemNames(50);
end

% If the number of cached names is too small, expand it and recache.
if (numberOfItems > numel(namesCell))
    namesCell = generateItemNames(numberOfItems);
end

% Return the first n item names.
itemNames = namesCell(1:numberOfItems);
end


function namesCell = generateItemNames(numberOfItems)

namesCell = cell(1, numberOfItems);
for idx = 1:numberOfItems
    namesCell{idx} = sprintf('Item_%d', idx);
end
end
        
%{
function uint8Value = convertToUint8(value, group, element, VR)

attrStruct.Group = group;
attrStruct.Element = element;
attrStruct.VR = VR;

uint8Value = massageData(value, attrStruct);

end


function data_out = massageData(data_in, attr_str)
%MASSAGE_DATA   Convert data to its DICOM type.

% We assume that this won't be called on data that can't be converted.
% The function HAS_CORRECT_DATA_TYPE permits this assumption.

switch (attr_str.VR)
case 'AT'
    % Attribute tags must be stored as UINT16 pairs.
    data_out = uint16(data_in);
    
    if (numel(data_out) ~= length(data_in))
        if (size(data_out, 2) ~= 2)
            error(message('images:dicom_add_attr:AttributeNeedsPairsOfUint16Data', sprintf( '(%04X,%04X)', attr_str.Group, attr_str.Element )))
        end
        
        data_out = data_out';
    end
    
    data_out = images.internal.dicom.typecast(data_out(:), 'uint8');
    
case 'DA'
    % Convert a MATLAB serial date to a string.
    if (isa(data_in, 'double'))
        warning(message('images:dicom_add_attr:serialDateToString', sprintf('(%04X,%04X)', attr_str.Group, attr_str.Element)))
        
        tmp = datestr(data_in, 30);  % yyyymmddTHHMMSS
        data_out = tmp(1:8);
    else
        data_out = data_in;
    end
    
        data_out = native2unicode(data_out, 'utf-8');
    
case 'DS'
    % Convert numeric values to strings.
    if (~ischar(data_in))
        data_out = images.internal.dicom.convertNumericToString(data_in);
    else
        data_out = data_in;
    end
    
    data_out = native2unicode(data_out(:), 'utf-8');
    
case 'DT'
    % Convert a MATLAB serial date to a string.
    if (isa(data_in, 'double'))
        warning(message('images:dicom_add_attr:serialDateToString', sprintf( '(%04X,%04X)', attr_str.Group, attr_str.Element )))
        
        data_out = '';
        
        for p = 1:length(data_in)
            tmp_base = datestr(data_in, 30);  % yyyymmddTHHMMSS
            tmp_base(9) = '';
            
            v = datevec(data_in);
            tmp_fraction = sprintf('%0.6f', (v(end) - round(v(end))));
            tmp_fraction(1) = '';  % Remove leading 0.
            
            data_out = [data_out '\' tmp_base tmp_fraction(2:end)]; %#ok<AGROW>
        end
    else
        data_out = data_in;
    end
    
    data_out = native2unicode(data_out(:), 'utf-8');
    
case 'FD'
    data_out = double(data_in);
    data_out = images.internal.dicom.typecast(data_out(:), 'uint8');
    
case 'FL'
    data_out = single(data_in);
    data_out = images.internal.dicom.typecast(data_out(:), 'uint8');
    
case 'IS'
    % Convert numeric values to strings.
    if (~ischar(data_in))
        data_out = sprintf('%d\\', round(data_in));
        data_out(end) = '';
    else
        data_out = data_in;
    end

    data_out = native2unicode(data_out(:), 'utf-8');
    
case 'OB'
    % Convert logical values to packed UINT8 arrays.
    if (islogical(data_in))
        data_out = images.internal.dicom.packLogical(data_in, 8);
    else
        data_out = data_in;
    end
    
    data_out = images.internal.dicom.typecast(data_out(:), 'uint8');
    
case 'OW'
    if (islogical(data_in))
        % Convert logical values to packed UINT8 arrays.
        data_out = images.internal.dicom.packLogical(data_in, 16);
    elseif (isa(data_in, 'uint32') || isa(data_in, 'uint32'))
        % 32-bit values need to be swapped as 16-bit short words not
        % 32-bit words (e.g., "1234" byte order on LE should become
        % "2143" on BE machines, and vice versa).
        data_out = images.internal.dicom.typecast(data_in, 'uint16');
    else
        data_out = data_in;
    end
    
    data_out = images.internal.dicom.typecast(data_out(:), 'uint8');
    
case 'PN'
    % PN values are no longer stored as structs.
    data_out = native2unicode(data_in(:), 'utf-8');
    
case 'SL'
    data_out = int32(data_in);
    data_out = images.internal.dicom.typecast(data_out(:), 'uint8');
    
case 'SS'
    data_out = int16(data_in);
    data_out = images.internal.dicom.typecast(data_out(:), 'uint8');
    
case 'TM'
    % Convert a MATLAB serial date to a string.
    if (isa(data_in, 'double'))
        warning(message('images:dicom_add_attr:serialDateToString', sprintf( '(%04X,%04X)', attr_str.Group, attr_str.Element )))
        
        tmp = datestr(data_in, 30);  % yyyymmddTHHMMSS
        data_out = tmp(10:end);
    else
        data_out = data_in;
    end
    
    data_out = native2unicode(data_out(:), 'utf-8');
    
case 'UL'
    data_out = uint32(data_in);
    data_out = images.internal.dicom.typecast(data_out(:), 'uint8');
    
case 'UN'
    if (isnumeric(data_in))
        data_out = images.internal.dicom.typecast(data_in, 'uint8');
    else
        data_out = data_in;
        data_out = native2unicode(data_out(:), 'utf-8');
    end
    
case 'US'
    data_out = uint16(data_in);
    data_out = images.internal.dicom.typecast(data_out(:), 'uint8');
    
case {'US/SS', 'SS/US'}
    if (any(data_in < 0))
        data_out = int16(data_in);
    else
        data_out = uint16(data_in);
    end
    
    data_out = images.internal.dicom.typecast(data_out(:), 'uint8');
    
otherwise
    data_out = unicode2native(data_in, 'utf-8');
    
end
end
%}


function thisSerializedAttr = serializeOneAttribute(thisAttr, txfr, uidDetails, swapFile, swapMeta, swapPixel)

PIXEL_GROUP   = sscanf('7fe0', '%x');
PIXEL_ELEMENT = sscanf('0010', '%x');

if (thisAttr.Group == 2)
    
    thisSerializedAttr = create_encoded_attr(thisAttr, uidDetails, swapFile);
    
elseif ((thisAttr.Group == PIXEL_GROUP) && ...
        (thisAttr.Element == PIXEL_ELEMENT))
    
    thisSerializedAttr = create_encoded_attr(thisAttr, uidDetails, swapPixel);
    
    % GE format has different endianness within the PixelData
    % attribute.  Fix it.
    if (isequal(txfr, '1.2.840.113619.5.2'))
        thisSerializedAttr = fix_pixel_attr(thisSerializedAttr);
    end
    
else
    
    thisSerializedAttr = create_encoded_attr(thisAttr, uidDetails, swapMeta);
    
end
end


function segment = create_encoded_attr(attr, uidDetails, swap)

% If it's a sequence, recursively enocde the items and attributes.
if (isstruct(attr.Data))
    byteStream = [];
    
    for idx = 1:numel(attr.Data)
        thisAttr = attr.Data(idx);
        
        thisSerializedAttr = serializeOneAttribute(thisAttr, [], uidDetails, swap, swap, swap);
        byteStream = addToByteStream(byteStream, thisSerializedAttr);
    end
    
    attr.Data = byteStream;
end

% Determine size of data.
switch (class(attr.Data))
case {'uint8', 'int8', 'char'}
    data_size = 1;
    
case {'uint16', 'int16'}
    data_size = 2;
    
case {'uint32', 'int32', 'single'}
    data_size = 4;
    
case {'double'}
    data_size = 8;
    
end

% Group and Element
segment = images.internal.dicom.typecast(uint16(attr.Group), 'uint8', swap);
segment = [segment images.internal.dicom.typecast(uint16(attr.Element), 'uint8', swap)];

% VR and Length
if ((isequal(uidDetails.VR, 'Implicit')) && (attr.Group > 2))
    % VR does not appear in the file.
    len = uint32(data_size * length(attr.Data));
else
    % VR.
    segment = [segment uint8(attr.VR)];
    
    % Determine length.
    switch (attr.VR)
    case {'OB', 'OW', 'SQ'}
        segment = [segment uint8([0 0])];  % Padding.
        len = uint32(data_size * length(attr.Data));
            
    case {'UN'}
        if (attr.Group == 65534)  % 0xfffe
            % Items/delimiters don't have VR or two-byte padding.
            segment((end - 1):end) = [];
        else
            segment = [segment uint8([0 0])];  % Padding.
        end
        
        len = uint32(data_size * length(attr.Data));
            
    case {'UT'}
        % Syntactically this is read the same as OB/OW/etc., but it
        % cannot have undefined length.
        segment = [segment uint8([0 0])];  % Padding.
        len = uint32(data_size * length(attr.Data));
            
    case {'AE','AS','AT','CS','DA','DS','DT','FD','FL','IS', ...
          'LO','LT', 'PN','SH','SL','SS','ST','TM','UI','UL','US'} 
        len = uint16(data_size * length(attr.Data));
        
    otherwise
        % PS 3.5-1999 Sec. 6.2 indicates that all unknown VRs can be
        % interpretted as being the same as OB, OW, SQ, or UN.  The
        % size of data is not known but, the reading structure is.  
        segment = [segment uint8([0 0])];  % Padding.
        len = uint32(data_size * length(attr.Data));
        
    end

    % Special case for length of encapsulated (7FE0,0010).
    if (((attr.Group == 32736) && (attr.Element == 16)) && ...
        (uidDetails.Compressed == 1))
        
        % Undefined length.
        len = images.internal.dicom.UNDEFINED_LENGTH();
        
    end
    
end

% If the data length is odd, then we will have to pad it.  Add one to the
% length of the attribute.
if ((len ~= images.internal.dicom.UNDEFINED_LENGTH()) && (rem(len, 2) ~= 0))
    len = len + 1;
end
    
% Add the length and data to the segment.
segment = [segment images.internal.dicom.typecast(len, 'uint8', swap)];

if (ischar(attr.Data))
    segment = [segment uint8(attr.Data(:)')];
else
    tmp = images.internal.dicom.typecast(attr.Data, 'uint8', swap);
    segment = [segment tmp(:)'];
end

% Pad the data (if necessary) by adding a null byte.
if (rem(numel(segment), 2) ~= 0)
    segment(end + 1) = 0; 
end

end


function byteStream = addToByteStream(byteStream, thisSerializedAttr)

byteStream = [byteStream thisSerializedAttr];

end


function numericValue = convertToNumeric(value)

if (ischar(value))
    numericValue = sscanf(value, '%x');
else
    numericValue = value;
end

end
