function rType = getSimpleType(mediaType)
% Convert the MediaType (which has Type and Subtype with values such as text/plain,
% application/json, etc), to a simplified form telling us how to convert the data:
% json, image, table, xmldom, text, audio or binary.  Returns 'binary' if the Type
% and Subtype aren't recognized.
%
% For internal use only.

% Copyright 2016 The MathWorks, Inc.

    % The order in the if statement block is important. Some spreadsheet
    % mime-types contain the string 'xmldocument', so it needs to be parsed before
    % XML. XML content can be text/xml, so it needs to be parsed before text. CSV
    % content is text/csv so it needs to be parsed before text.

    if strcmpi(mediaType.Type,'application') && strcmpi(mediaType.Subtype,'json')
        % application/json
        rType = 'json';

    elseif strcmpi(mediaType.Type,'image')
        % image/jpeg, etc
        rType = 'image';

    elseif (strcmpi(mediaType.Type,'text') || strcmpi(mediaType.Type,'application')) && ...
           any(strcmpi(mediaType.Subtype, {'csv', 'comma-separated-values'}))
        % text/csv
        rType = 'table';
    elseif strcmpi(mediaType.Type,'application') && ...
            (~isempty(strfind(lower(mediaType.Subtype), 'spreadsheet')) || ...
             ~isempty(strfind(lower(mediaType.Subtype), 'ms-excel')))
        % spreadsheet (Excel)
        rType = 'table';
    elseif any(strcmpi(mediaType.Type,{'text','application'})) && strcmpi(mediaType.Subtype, 'xml')
        % text/xml, application/xml
        if usejava('jvm')
            rType = 'xmldom';
        else
            % treat like text if no JVM; charset assumed to be utf-8 if unspecified
            rType = 'text';
        end
    elseif isText(mediaType)
        % text/plain, text/html, application/javascript ... or anything with charset
        rType = 'text';
    elseif strcmpi(mediaType.Type, 'audio') || mediaType == matlab.net.http.MediaType('application/ogg')
        % audio
        rType = 'audio';
    else
        % default; note application/octet-stream comes here
        rType = 'binary';
    end
end

%--------------------------------------------------------------------------

function tf = isText(mediaType)
% Return true if mediaType implies the contents is text-based.  This is true for a
% major type of 'text', certain specific subtypes of 'application', and any mediaType
% that has a charset.

    containsText = strcmpi(mediaType.Type,'text') || ~isempty(mediaType.getParameter('charset'));
    % subtypes of 'application' that are text
    appTextSubtypes = {'javascript','x-javascript','x-www-form-urlencoded',...
        'vnd.wolfram.mathematica.package' % MATLAB file on some servers
        };
    tf = containsText || ...
        (strcmpi(mediaType.Type,'application') && ...
         any(strcmpi(mediaType.Subtype, appTextSubtypes)));
end

