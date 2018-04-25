function [decodeCharset,encodeCharset] = getCharsetForMediaType(mediaType)
% Given the mediaType (a type/subtype string) or MediaType, return the charset we
% should use to decode or encode it, if it's character data, or '' if not.
%
% For a MediaType that has an explicit charset parameter, return that in both
% decodeCharset and encodeCharset.  The two values may be different if the
% mediaType does not have an explicit charset. In that case decodeCharset is a charset
% that is equal to or a superset of the default charset for that type/subtype,
% if we know it, and encodeCharset is the documented default charset for that
% type/subtype.  If we don't recognize the type/subtype as being character data
% return ''.
%
% Some document types like text/xml have the charset specified in the document,
% not in a Content-Type field.  For these, decodeCharset is the most likely
% charset typically used for that media type.  This leads us to return utf-8 for
% many text/* types such as text/html and text/xml, even though the default is
% us-ascii. This is fine, because utf-8 is a superset of us-ascii.  For
% encoding, the default encodeCharset for text/* is always US-ASCII.  Callers
% who have non-ASCII characters in their document to encode must specify the intended
% charset explicitly.

% Copyright 2015-2017 The MathWorks, Inc.

    if ischar(mediaType) || isstring(mediaType)
        % if a string, assume it's 'type/subtype' with no explicit charset
        mtype = char(mediaType);
    else
        decodeCharset = mediaType.getParameter('charset');
        encodeCharset = decodeCharset;
        if ~isempty(decodeCharset)
            return
        else
            mtype = char(mediaType.Type + '/' + mediaType.Subtype);
        end
    end
    % No explicit charset; return default for the MediaType, if any.
    % For encoding, RFC 1341 says text/* is US-ASCII.  For anything else, assume
    % UTF-8.
    if strcmpi(mediaType.Type, 'text')
        encodeCharset = 'us-ascii';
    else
        encodeCharset = 'utf-8';
    end
    % The following content types are character data for which we can guess a default
    % encoding.
    switch (lower(mtype))
        case {'text/plain', 'text/csv'}
            decodeCharset = 'us-ascii';  
        % The default type for html was changed from iso-8859-1 in HTML 4 to utf-8 in
        % HTML 5.  Since we don't have access to the data, assume UTF-8.
        % For x-www-form-urlencoded, there is no default charset, but if one is
        % missing from the mediaType, the payload decode algorithm in 
        % http://www.w3.org/TR/html5/forms.html#application/x-www-form-urlencoded-decoding-algorithm
        % "suggests" UTF-8.  For text/xml, we specify utf-8 because that's the
        % charset that xmlwrite uses, which is what we'll call to convert a user's DOM
        % to a string.
        case {'application/json', 'text/html', 'text/xml', 'text/javascript', ...
              'application/xhtml+xml', 'application/xml', 'text/css', 'text/calendar', ...
              'application/x-www-form-urlencoded', 'application/javascript', 'application/css'}
            decodeCharset = 'utf-8';
        % TBD More?
        otherwise
            if strcmpi(mediaType.Type, 'text')
                % Unknown text type.  Decode using utf-8 even though the default for text is ASCII,
                % since utf-8 is superset.  If it contains non-ASCII utf-8 data, it will be properly
                % decoded.
                decodeCharset = 'utf-8';
            else
                % Return an empty charset because we don't know the default charset.  For
                % character data, the caller may need to derive the charset based on the data.
                decodeCharset = '';
                encodeCharset = '';
            end
    end
end
            
        