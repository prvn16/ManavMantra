classdef RequestMethod 
% matlab.net.http.RequestMethod An HTTP request method
%   This is an enumeration of possible HTTP request methods.  This value should be
%   set in the RequestMessage's Method property.  The methods supported are
%   those listed in the <a href="http://www.iana.org/assignments/http-methods/http-methods.xhtml">IANA Hypertext Transfer Protocol (HTTP) Method Registry</a> 
%   as of 1 May 2016.
%
%   RequestMethod members:
%     ACL
%     BASELINECONTROL
%     BIND
%     CHECKIN
%     CHECKOUT
%     CONNECT
%     COPY
%     DELETE
%     GET
%     HEAD
%     LABEL
%     LINK
%     LOCK
%     MERGE
%     MKACTIVITY
%     MKCALENDAR
%     MKCOL
%     MKREDIRECTREF
%     MKWORKSPACE
%     MOVE
%     OPTIONS
%     ORDERPATCH
%     PATCH
%     POST
%     PRI
%     PROPFIND
%     PROPPATCH
%     PUT
%     REBIND
%     REPORT
%     SEARCH
%     TRACE
%     UNBIND
%     UNCHECKOUT
%     UNLINK
%     UNLOCK
%     UPDATE
%     UPDATEREDIRECTREF
%     VERSIONCONTROL
%
%   RequestMethod methods:
%     string   - return the request method as a string
%     char     - return the name of the enumeration member as a character vector
%
% See also matlab.net.http.RequestMessage

% Copyright 2015-2016 The MathWorks, Inc.
    enumeration
        ACL
        BASELINECONTROL
        BIND
        CHECKIN
        CHECKOUT
        CONNECT
        COPY
        DELETE
        GET
        HEAD
        LABEL
        LINK
        LOCK
        MERGE
        MKACTIVITY
        MKCALENDAR
        MKCOL
        MKREDIRECTREF
        MKWORKSPACE
        MOVE
        OPTIONS
        ORDERPATCH
        PATCH
        POST
        PRI
        PROPFIND
        PROPPATCH
        PUT
        REBIND
        REPORT
        SEARCH
        TRACE
        UNBIND
        UNCHECKOUT
        UNLINK
        UNLOCK
        UPDATE
        UPDATEREDIRECTREF
        VERSIONCONTROL
    end
    
    methods
        function str = string(obj)
        % string Returns the name of the request method as a string, as it would
        %   appear in a RequestLine.  This is not necessarily identical to the
        %   enumeration name.
        %
        % See also RequestLine
            str = string(char(obj));
            if str.endsWith('CONTROL')
                str = str.insertBefore(strlength(str)-6,'-');
            end
        end
    end

end