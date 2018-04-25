function localizedValue = localizePN(byteStream, metadata, varargin)

% Copyright 2015-2017 The MathWorks, Inc.

specificCharacterSet = images.internal.dicom.getSpecificCharacterSet(metadata, varargin{:});

splitRawData = tokenizeRawData(byteStream, '\');

localizedValue = '';
for p = 1:numel(splitRawData)
    if (hasMultiplePNComponents(splitRawData{p}))
        unicodeString = convertMultipleComponentsToUnicode(splitRawData{p}, ...
            specificCharacterSet);
    else
        unicodeString = getUnicodeStringFromBytes(splitRawData{p}, ...
            specificCharacterSet{1});
    end
    
    unicodeString = images.internal.dicom.deblankAndStripNulls(unicodeString);
    localizedValue = [localizedValue unicodeString]; %#ok<AGROW>
end

end


function unicodeString = getUnicodeStringFromBytes(byteStream, originalCharacterSet)

icuCharacterSet = images.internal.dicom.getConverterString(originalCharacterSet);

% Remove a particular control code sequence ICU doesn't handle well.
byteStream = uint8(strrep(char(byteStream), char([27 36 41 67]), ''));
unicodeString = native2unicode(byteStream, icuCharacterSet);

end


function TF = hasMultiplePNComponents(rawData)

if (~isempty(rawData))
    TF = ~isempty(find(rawData == '=', 1));
else
    TF = false;
end
end


function unicodeString = convertMultipleComponentsToUnicode(rawData, specificCharacterSet)

% Components are divided by equal signs ('=')
separatorIndices = find(rawData == uint8('='));

unicodeString = '';

start = 1;
for p = 1:numel(separatorIndices)
    
    if (p == 1)
        targetCharSet = specificCharacterSet{1};
    else
        targetCharSet = specificCharacterSet{end};
    end
    
    stop = separatorIndices(p) - 1;
    substring = rawData(start:stop);
    substring = getUnicodeStringFromBytes(substring, targetCharSet);
    unicodeString = [unicodeString '=' substring]; %#ok<AGROW>
    
    start = separatorIndices(p) + 1;
end

substring = rawData(start:end);
substring = getUnicodeStringFromBytes(substring, specificCharacterSet{end});
unicodeString = [unicodeString '=' substring];
unicodeString(1) = '';  % Remove leading '='

end


function splitRawData = tokenizeRawData(rawData, delimiter)

if isempty(rawData)
    splitRawData = {};
    return
end

delimiterLocations = find(rawData == uint8(delimiter));

if isempty(delimiterLocations)
    splitRawData = {rawData};
    return
end

splitRawData = cell(1, numel(delimiterLocations) + 1);

start = 1;
for p = 1:numel(delimiterLocations)
    stop = delimiterLocations(p) - 1;
    if (stop >= start)
        splitRawData{p} = rawData(start:stop);
    end
    start = stop + 2;
end

splitRawData{end} = rawData(start:end);

end
