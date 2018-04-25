function suffix = getSuffixForSubtype(simpleType, subtype)
% Return the temp file suffix that should be used when reading or writing data
%    in a temp file for a give simple type and subtype.  This is the suffix
%    that the data converter such as readtable, writetable, audioread, etc.
%    requires to do the required conversion.
%
%    simpleType - one of the simpleTypes that MATLAB recognizes (see
%                 matlab.net.http.internal.getSimpleType)
%    subtype    - a string representing the subtype
%    suffix     - a char vector, which could be '' if no suffix is required, or []
%                 if the subtype is unknown.  We assume all simpleTypes that
%                 aren't handled specifically below don't need special
%                 suffixes.
%
% For internal use only.

% Copyright 2016-2017 The MathWorks, Inc.

    suffix = '';
    
    subtype = lower(subtype);
    switch simpleType
        % audioread requires audio files to have special suffixes on all platforms
        % readtable needs Excel suffixes on Linux and maybe Mac
        case 'audio'
            if subtype.endsWith('wav')
                suffix = 'wav';
            elseif subtype.endsWith('mpeg3') || subtype.endsWith('mpeg-3') || subtype.endsWith('mpeg') || subtype.endsWith('mp3')
                suffix = 'mp3';
            elseif subtype.endsWith('aiff')
                suffix = 'aiff';
            elseif subtype.endsWith('mpeg-4') || subtype.endsWith('mpeg4')
                suffix = 'mp4';
            else
                switch subtype
                    case {'basic', 'x-au'}
                        suffix = 'au';
                    case {'mp4', 'm4a'}
                        suffix = 'mp4';
                    case 'ogg'
                        suffix = 'ogg';
                    case {'flac' 'x-flac'}
                        suffix = 'flac';
                    otherwise
                        suffix = [];
                end
            end
        case 'table'
            % This list of table MIME types and suffixes from 
            % http://www.sitepoint.com/web-foundations/mime-types-summary-list/
            switch subtype
                case 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                    suffix = 'xlsx';
                case 'vnd.ms-excel.addin.macroenabled.12'
                    suffix = 'xlam';
                case 'vnd.ms-excel.sheet.macroenabled.12'
                    suffix = 'xlsm';
                case 'vnd.ms-excel.template.macroenabled.12'
                    suffix = 'xltm';
                case 'vnd.ms-excel'
                    suffix = 'xls';
                case 'vnd.ms-excel.sheet.binary.macroenabled.12'
                    suffix = 'xlsb';
                case 'vnd.openxmlformats-officedocument.spreadsheetml.template'
                    suffix = 'xltx';
                case 'csv'
                    suffix = 'csv';
                otherwise
                    % just in case other types we haven't thought of
                    suffix = 'xlsx';
            end
    end
end