function [matlabTypeToType, subtypeToMatlabType, suffixToType, typeToSuffix] = getTypeMaps()
% Return the maps of types to be used for conversion of MATLAB data or reading web content:
%    matlabTypeToType(matlabType) returns  {type,subtype}
%       This is useful for converting a MATLAB type or file suffix to a
%       MediaType, when the user does not specify one.  It's used to derive the
%       MediaType from the data.
%    subtypeToMatlabType(subtype) returns  {type,matlabType}
%       This returns the type and MATLAB type for a subtype.  This is useful for
%       determining the converter function (imwrite, audiowrite, etc.) which is based on
%       the type, and the format (matlabType) parameter to the function.  It's
%       only used with subtypes that were specified by the user in a MediaType,
%       or which were returned by matlabTypeToType.
%    suffixToType(suffix) returns {type,subtype}
%       This returns a type/subtype given a filename extension.  It contains all
%       the mappings of matlabTypeToType(suffix) plus additional mappings for
%       suffixes that are not "MATLAB types".
%    typeToSuffix(type) given 'type/subtype' returns a file suffix (extension)
%       This map is designed to map a Content-Type to a file extension.  It only
%       works for audio, image and spreadsheet types.  Caller needs to worry
%       about other types.
% The matlabType is a format parameter to the appropriate converter, which may
% also be a filename extension, and/or a type we define in our data2payload
% function (e.g., "text" and "spreadsheet").  A MATLAB type may map to more than
% one type/subtype.  In that case the last mapping is the "preferred" one, which
% we use when the caller does not specify a subtype.
%
% The first time this is called, the maps are created.  Subsequent calls return
% the cached maps.
%
% The first two maps only contain types for MATLAB data whose type and subtype are not
% obviously distinguishable by its class.  For example we don't include text/xml
% because the class of the data has to be a Xerces XML DOM.
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/http. Its behavior
%   may change, or the function itself may be removed in a future release.

% Copyright 2017 The MathWorks, Inc.

    persistent matlabTypeToTypeMap subtypeToMatlabTypeMap suffixToMediaTypeMap typeToSuffixMap
    if isempty(matlabTypeToTypeMap)
        % In this array, types{i} is the MATLAB type and possibly also a file suffix, and
        % types{i+1} is the type and subtype.  These will be used to construct the 3
        % returned maps. In this map, types{i} should not list any values that might be
        % file suffixes, unless that suffix corresponds to the type/subtype listed.  For
        % example it maps "text" to "text/csv", which means all .text files would be
        % interpreted as text/csv files.  This would be incorrect, except that we don't
        % expect a file to ever have a .text suffix. 
        types = ...
            {... % Types for imwrite
             'bmp',{'image','bmp'},              'gif',{'image','gif'}, ...
             'hdf',{'image','x-hdf'},            'jpg',{'image','jpeg'}, ...
             'jpeg',{'image','jpeg'},            'jp2',{'image','jp2'}, ...
             'jpx',{'image','jpx'},              'pbm',{'image','x-portable-bitmap'}, ...
             'pcx',{'image','x-pcx'},            'pgm',{'image','x-portable-graymap'}, ...
             'png',{'image','png'},              'pnm',{'image','x-portable-anymap'}, ...
             'ppm',{'image','x-portable-pixmap'},'ras',{'image','x-cmu-raster'}, ...
             'tif',{'image','tiff'},             'tiff',{'image','tiff'}, ...
             'xwd',{'image','x-xwd'}, ...
             ... % Types for audiowrite, which is platform-dependent 
             'wav',{'audio','x-wav'},            'wav',{'audio', 'vnd.wav'}, ...
             'wav',{'audio','wav'}, ...
             'ogg',{'application','ogg'},        'mp4',{'audio','mp4'}, ...
             'flac',{'audio','flac'}, ...
             ... % Types for writetable
             'text',{'application','csv'},       'text',{'text','csv'}, ...
             'spreadsheet',{'application','vnd.openxmlformats-officedocument.spreadsheetml.template'}, ...
             'spreadsheet',{'application','vnd.ms-excel.addin.macroenabled.12'}, ...
             'spreadsheet',{'application','vnd.ms-excel.sheet.macroenabled.12'}, ...
             'spreadsheet',{'application','vnd.ms-excel.sheet.binary.macroenabled.12'}, ...
             'spreadsheet',{'application','vnd.ms-excel'}, ...
             'spreadsheet',{'application','vnd.openxmlformats-officedocument.spreadsheetml.sheet'}
            };
        % Additional types for converting file suffix to MediaType, where the file
        % suffix is not a "MATLAB type".  For example "json" is not a MATLAB type
        % because it's never used as an argument to a converter and because it's not in
        % our list of MATLAB types processed by data2payload.  The keys are additional
        % suffixes that aren't already listed in types{i}{1} above.  These will only be
        % included in the suffixToMediaType return value.
        additionalTypes = {
            'txt',{'text','plain'}, ...
            'm',{'text','plain'}, ...
            'xml',{'application','xml'}, ...
            'json',{'application','json'}, ...
            'csv',{'text','csv'}, ...
            'html',{'text','html'}, ...
            'htm',{'text','html'}
            };
        % in this map, 'wav' returns {'audio','wav'}.
        matlabTypeToTypeMap = containers.Map;
        % in this map, 'x-wav' returns {'audio','wav'}
        subtypeToMatlabTypeMap = containers.Map;
        % in this map, 'json' returns {'application','json'}
        suffixToMediaTypeMap = containers.Map;
        % in this map, 'text/plain' returns '.txt'
        typeToSuffixMap = containers.Map;
        for i = 1 : 2 : length(types)
            mtype = types{i};
            type = types{i+1}{1};
            subtype = types{i+1}{2};
            typeSubtype = types{i+1};
            subtypeToMatlabTypeMap(subtype) = {type, mtype};
            %  This may overwrite the earlier mapping from MATLAB type to type/subtype,
            %  but that's OK since the last one is the one we use.
            matlabTypeToTypeMap(mtype) = typeSubtype;
            suffixToMediaTypeMap(mtype) = typeSubtype;
            typeSubtype = char(strjoin(typeSubtype,'/'));
            if any(strcmp(type, {'image' 'audio'}))
                % the typeToSuffixMap can contain all the image and audio types from the table
                % directly, because the MATLAB type is the same as the suffix
                typeToSuffixMap(typeSubtype) = mtype;
            elseif strcmp(mtype,'spreadsheet')
                % for spreadsheet types, get the suffix from getSuffixForSubtype()
                typeToSuffixMap(typeSubtype) = ...
                    matlab.net.http.internal.getSuffixForSubtype('table', subtype);
            end
        end
        % add additional types to suffixToMediaTypeMap
        for i = 1 : 2 : length(additionalTypes)
            suffixToMediaTypeMap(additionalTypes{i}) = additionalTypes{i+1};
        end
    end
    matlabTypeToType = matlabTypeToTypeMap;
    subtypeToMatlabType = subtypeToMatlabTypeMap;
    suffixToType = suffixToMediaTypeMap;
    typeToSuffix = typeToSuffixMap;
end    