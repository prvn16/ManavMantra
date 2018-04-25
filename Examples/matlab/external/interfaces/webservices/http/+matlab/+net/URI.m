classdef (Sealed) URI 
    %URI Internet Uniform Resource Identifier
    %  This class models an Internet URI such as web address or Uniform Resource
    %  Locator (URL).  An Internet URI is a string that is logically divided into
    %  a number of components.  Each component is represented by a property of
    %  this class that you can specify individually or all at once in the URI
    %  constructor.  When you use the string or char method to produce a URI
    %  string from this object, these properties are encoded by adding punctuation
    %  to separate nonempty components and escaping reserved characters.  The
    %  following shows the components and their associated punctuation, separated
    %  by spaces for clarity:
    %
    %  Scheme<a href=""></a>: //Authority /Path(1) /Path(2) ... /Path(end) ?Query #Fragment
    %
    %  where Authority is further broken down as:
    %
    %      UserInfo@ Host :Port
    %
    %  The Path is a vector of strings, Port is a number, Query is a
    %  QueryParameter, and the others are scalar strings.  Strings may be set
    %  using either a character vector or string object. The spaces above do not
    %  appear in the encoded URI.  The associated punctuation is not part of the
    %  property value, except for properties that combine multiple components.
    %
    %  All components are optional, and any property of this object may be set to []
    %  to eliminate it and its associated punctuation from the output string.  But
    %  various uses may require certain components to be set.
    %
    %  URI methods:
    %
    %    string, char   - return URI as an encoded string
    %    eq, ==         - compare URIs for equality
    %
    %  URI properties:
    %    URI              - constructor
    %    Scheme, UserInfo, Host, Port, Path, Query, Fragment - see above
    %    Absolute         - true if URI is absolute
    %    EncodedAuthority - the Authority (UserInfo@Host:Port) as an encoded string
    %    EncodedPath      - the Path as an encoded string
    %    EncodedQuery     - the Query as an encoded string
    %    EncodedURI       - the entire URI as an encoded string
    %
    %  See also QueryParameter, matlab.net.http.RequestMessage, webread, webwrite,
    %  websave
    
    % Copyright 2015-2017 The Mathworks, Inc.
    
    properties
        % NOTE: order of declaration of these and dependent properties is intentional,
        % so they appear in the default display in desired order.
        
        % Scheme - the scheme, sometimes called "protocol" appearing before '://' 
        %   If not empty, it is generally 'http' or 'https'.  However, this is not
        %   enforced.  MATLAB HTTP services do not support other schemes such as
        %   'file'.  This property always returns a string.
        Scheme string
        
        % UserInfo - User information, such as 'name' or 'name:password'  
        %   If present this appears before the Host name followed by an '@' character.
        %   Special characters in this string will be percent-encoded when this URI is
        %   converted to a string.  When setting this property, do not encode it
        %   yourself.  This property always returns a string.
        %
        % See also string
        UserInfo string
        
        % Host - the host, a string in DNS name format or IPv4 or IPv6 address
        %   If it contains any characters not allowed in the Host portion of a URI
        %   they will be percent-encoded when this URI is converted to a string.  The '.'
        %   character will be unchanged.  When setting this property, do not encode
        %   it yourself.  This property always returns a string.
        %
        % See also string
        Host string
        
        % Port - a number or string in the range 0-65535, stored as a uint16.  
        Port
    end
    
    properties (Dependent)
        
        % EncodedAuthority - the Authority portion of the URI
        %   This property is a combination of the UserInfo, Host and Port, represented
        %   as an encoded string with associated punctuation appearing only if the
        %   property is nonempty.
        %      UserInfo@ Host :Port
        %   Spaces are added above to show associated punctuation--spaces do not
        %   appear in the result.  Setting this property is a shortcut to setting all
        %   three properties, except that you must encode any special characters
        %   yourself.
        EncodedAuthority string
    end
    
    properties (Dependent, Access={?matlab.net.http.internal.HTTPConnector, ...
                                   ?matlab.net.http.field.HostField})
        EncodedHost string       % The host, encoded, or an empty string
        EncodedHostPort string   % The host with port, encoded, or an empty string
    end
    
    properties
        % Path - a vector of strings representing segments of the path  
        %   You can set this value using a character vector, cell array of character
        %   vectors or vector of strings.  The result is always a vector of strings.
        %
        %   A path in a URI (as returned by the EncodedPath property) is typically
        %   depicted as a series of segments separated by the '/' character, where
        %   each of those segments is a member of this Path vector:
        %
        %     Path(1)/Path(2)/Path(3)/.../Path(end)
        %
        %   The '/' characters do not appear in this vector, but the EncodedPath
        %   contains them them when it returns this vector as a single string.
        %
        %   Note that there is always one more path segment than the number of '/'
        %   characters in the EncodedPath, and any segment can be an empty string: if
        %   Path(1) is an empty string, the EncodedPath begins with a '/', and if
        %   Path(end) is an empty string, the EncodedPath ends with a '/'.
        %
        %   If you set this property to a nonscalar vector of strings or a cell array
        %   of character vectors, any characters not allowed in the path portion of a
        %   URI will be percent-encoded in the EncodedPath.  When setting this
        %   property, do not encode the strings yourself, as percent signs will be
        %   encoded again (see example 4 below).
        %
        %   Examples of cell array or string vector input:
        %     1. {'foo' 'bar'}      encoded as 'foo/bar'
        %     2. {'foo bar'}        encoded as 'foo%20bar'
        %     3. {'abc' 'foo/bar'}  encoded as 'abc/foo%2Fbar'
        %     4. {'foo%2Fbar'}      encoded as 'foo%252Fbar'
        %
        %   As a special (but most common) case, if you set this property to a
        %   character vector or scalar string that contains any '/' characters, the
        %   string will be split into segments at those '/' characters, exactly as if
        %   you had specified a vector of strings or cell array of character vectors:
        %
        %    Examples of character vector or scalar string input:
        %      1. '/foo/bar'  becomes 3 segments: ["" "foo" "bar"]     (absolute)
        %      2. '/foo/bar/' becomes 4 segments: ["" "foo" "bar" ""]  (absolute)
        %      3. '/'         becomes 2 segments: ["" ""]              (absolute)
        %      4. 'foo/bar'   becomes 2 segments: ["foo" "bar"]        (relative)
        %      5. 'foo//bar'  becomes 3 segments: ["foo" "" "bar"]     (relative)
        %    Example of cell array input:
        %      6. {'foo/bar'} becomes 1 segment:  ["foo/bar"]          (relative)
        %
        %   Example 6 shows that '/' characters in a cell array (or equivalently,
        %   nonscalar string vector) become part of a segment, rather than a path
        %   separator, and will be encoded as %2F in the EncodedPath.
        %
        %   A path may be relative or absolute, as indicated in the last column above.
        %   An absolute path is a nonempty path whose first segment is empty, encoded
        %   with a leading '/'.  A relative path is one whose first segment is
        %   nonempty, encoded without a leading '/'.
        %
        %    >> import matlab.net.URI
        %    >> uri1 = URI;
        %    >> uri1.Path = {'' 'foo' 'bar'};       % set absolute Path
        %    >> disp(uri1.EncodedPath)
        %    /foo/bar
        %
        %    >> uri2 = URI;      
        %    >> uri2.Path = {'foo' 'bar'};          % set relative Path
        %    >> disp(uri2.EncodedPath)
        %    foo/bar
        %
        %   This definition of absolute path corresponds to path-absolute defined in
        %   RFC 3986, <a href="http://tools.ietf.org/html/rfc3986#section-3.3">section 3.3</a>.
        %
        %   If the URI contains a Scheme or Authority, and the Path has any value
        %   other than [], EncodedPath always begins with a leading '/' regardless of
        %   whether the Path is relative or absolute, as the slash is required to
        %   separate Scheme and Authority from the Path in the EncodedURI.  Thus URIs
        %   with two otherwise identical paths, one relative and one absolute, will
        %   result in the same EncodedURI (as returned by the string method, if those
        %   URIs contain the same Host.  Using the values from above:
        %
        %    >> uri1.Host = 'www.mathworks.com';
        %    >> uri2.Host = 'www.mathworks.com';
        %    >> disp(string(uri1))
        %    //www.mathworks.com/foo/bar
        %    >> disp(string(uri2))
        %    //www.mathworks.com/foo/bar
        %
        %   Therefore the distinction between absolute and relative paths matters only
        %   for URIs that contain no Scheme or Authority.  The eq (==) and isequal
        %   functions also consider uri1 and uri2 above to be equal.  
        %
        %   If you set this property to a cell array of character vectors or nonscalar
        %   vector of strings, and you want this path to appear with a leading '/',
        %   you do not need to insert an empty segment in the front unless you are
        %   using this URI without a Scheme or Authority, for example to represent an
        %   absolute path on your file system.
        %
        %   Include an empty string at the end of the Path vector if you want your
        %   EncodedPath to include a trailing '/'.  This is normally necessary only if
        %   you need to explicitly tell the server that your Path refers to a
        %   directory--most servers do not require this.  
        %
        %   A root path is one that points to the root.  It is set as string.empty,
        %   "/", or ["" ""] and encoded as "/".  An empty path indicates no path is
        %   set, and is set as [] or an empty string.  The appearance of EncodedPath
        %   for these cases depends on whether a Scheme or Authority are specified,
        %   indicated in the last two columns below.
        %                                                            EncodedPath
        %                                                     Without           With
        %   case  example    #segments  Path              Scheme/Authority Scheme/Authority
        %   ----  -------    ---------  ----------------  --------------   --------------
        %    1.  "foobar"        1      ["foobar"]        "foobar"         "/foobar"
        %    2.  "foo" ""        2      ["foo" ""]        "foo/"           "/foo/"
        %    3.  "foo/bar"       1      ["foo" "bar"]     "foo/bar"        "/foo/bar"
        %    4. {'/foo/bar'}     1      ["/foo/bar"]      "%2Ffoo%2Fbar"   "/%2Ffoo%2Fbar"
        %    5. ["foo" "bar"}    2      ["foo" "bar"]     "foo/bar"        "/foo/bar"
        %    6. ["" "foo" "bar"] 3      ["" "foo" "bar"]  "/foo/bar"       "/foo/bar"
        %    7.  ""              1      ""                ""   (empty)     "/"
        %    8. ["" ""] or "/"   2      ["" ""]           "/"  (root)      "/"
        %    9.  string.empty    0      [0x0 string]      "/"  (root)      "/"
        %   10.  {}              0      [0x0 string]      "/"  (root)      "/"
        %   11.  []              0      [] (default)      ""   (empty)     ""
        %    
        %   In the "With Authority" case, in all cases except #11, a leading '/' is
        %   added to the front of EncodedPath if there is not one already, to act as a
        %   separator between the Scheme and/or Authority and the Path in the
        %   EncodedURI, thus forcing the Path to be be treated as if it was absolute.
        %   In the case where the Path is completely empty, you can use the value []
        %   instead of "" or string.empty to suppress the '/' that would otherwise
        %   appear after the end of the URI, but this affects only how the EncodedURI
        %   is displayed, not the meaning of it.
        %
        %   Cases 9 and 10 above, where Path is string.empty, are simply alternate
        %   (and more efficient) ways to refer to the root, compared to case 8, and
        %   the three are interchangeable for all uses, including comparison of URIs
        %   using eq (==).  Likewise, cases 7 and 11 are alternate ways to indicate an
        %   empty path and are also interchangeable, affecting only whether a trailing
        %   '/' appears in the EncodedURI in the "With Authority" case.  In the "With
        %   Authority case", all five of these (cases 7-11) are functionally
        %   equivalent and will compare equal if all other properties are equal.
        %
        % See also string, char, Host, Scheme, EncodedAuthority, EncodedPath,
        % EncodedURI, eq
        Path
        % We don't declare type "string" for Path because automatic coercion would
        % make it impossible for us to determine the difference between setting this
        % to [] vs. {} or string.empty (see cases 9, 10 and 11 above).
    end
    
    properties (Dependent)
        % EncodedPath - the encoded Path as a string
        %   Read this property to obtain the Path portion of the URI as an encoded
        %   string, as it would appear in the encoded URI.  If you have an
        %   already-encoded path as a character vector or string, set it through this
        %   property instead of the Path property to prevent further encoding.  As
        %   described for the Path property, EncodedPath will have a leading '/' if
        %   the Path is not [] and there are nonempty componenents in the URI prior to
        %   the Path, whether you specify any or not.
        %
        %   Setting this to an empty array ('', [], string.empty) or empty string
        %   ("") is equivalent to setting the Path to that value.  The return
        %   value of this property is always a string, possibly empty (i.e., "") if no
        %   Path would appear in encoded URI. It is never an empty array.
        %
        % See also string, Path
        EncodedPath
        % Don't declare string type above because we need to distinguish between []
        % and string.empty as per last paragraph of help above.
    end
    
    properties
        % Query - The query of a URI as a vector of matlab.net.QueryParameter
        %   You may set this property to a vector of QueryParameter or a string
        %   containing the entire query, with leading '?' optional.  The string you
        %   supply is assumed to be already encoded.  See the QUERYSTR argument to
        %   QueryParameter for more information on what you can provide as a string.
        %
        % See also matlab.net.URI.URI, matlab.net.QueryParameter.QueryParameter
        Query matlab.net.QueryParameter
    end
    
    properties (Dependent)
        % EncodedQuery - the encoded query string
        %   For URI u, this returns the same value as string(u.Query).  Setting this
        %   is equivalent to setting Query.
        %
        % See also Query, string
        EncodedQuery string
    end
       
    properties (Dependent)
        % Fragment - the Fragment in a URI
        %   If set, it is a string.  If it contains any characters not allowed in a
        %   fragment, they will be percent-encoded.  When setting this property, do not
        %   encode it yourself.
        Fragment string
    end
    
    properties (Access=private)
        % This is set to true if the Fragment was specified in the DESTINATION string 
        % to the URI constructor.  In that case we want to preserve exactly what the
        % user entered and not encode it.  If the Fragment property is directly set,
        % this flag is cleared.
        FragmentIsLiteral logical = false
        RealFragment string        % fragment as user entered it
    end
    
    properties (Dependent, SetAccess=private)
        % Absolute - true if the URI is absolute
        %   An absolute URI is one that has a nonempty Scheme.  If it is not
        %   absolute, it is considered to be relative.  This corresponds to the
        %   definition of absolute-URI in RFC 3986, <a href="http://tools.ietf.org/html/rfc3986#section-4.3">section 4.3</a>.
        %
        %   The Path in an absolute URI is always treated as an absolute path (and
        %   thus the EncodedPath will always contain a leading '/').  In order to send
        %   a message, the URI must be Absolute and must also contain an nonempty Host
        %   property.
        Absolute
    end
    
    properties (Dependent)
        % EncodedURI - the entire URI as an encoded string
        %   This property returns the same value as the string method.  If you set
        %   this property to a string STR, it is equivalent to creating a new URI this
        %   way:
        %       obj = URI(STR, 'literal');
        %
        % See also string
        EncodedURI string
    end
    
    properties (Dependent, Access=private)
        % Segments - Array of strings representing all segments of URI:
        %      [Scheme UserInfo Host(1:end) Port Path(1:end)]
        %   where Host(i) is each dot-delimited segment of the Host name.  Empty
        %   trailing properties are omitted, so a URI with just a Scheme, for example,
        %   has only one segment. Does not include initial empty segment of Path, but
        %   incldues trailing ones.  Used to simplify URI comparisons.
        Segments string
        % EncodedUserInfo - UserInfo, appropriately encoded
        %   This includes the trailing '@'.  If UserInfo is empty or an empty string,
        %   returns an empty string.
        EncodedUserInfo string
    end
    
    properties(Access=?matlab.net.QueryParameter, Constant)
        % Properties used in comparing URIs, right to left
        PropNames = flip({'Scheme','UserInfo','Host','Port','Path'})
        % sub-delims in RFC 3986
        SubDelims = '!$&''()*+,;=';
        % pchar, not including unreserved or pct-encoded
        Pchar = [matlab.net.URI.SubDelims ':@']
    end
    
    methods
        % GENERAL COMMENT: The string properties that are typed will be coerced to
        % string before getting into these methods, and this coersion converts [] to
        % string.empty.
        function obj = set.Scheme(obj, value)
            if ~isempty(value) 
                value = matlab.net.internal.getString(value, mfilename, 'Scheme');
                value = strtrim(value);
                if strlength(value) ~= 0
                    % This syntax for a valid scheme is from RFC 3986 section 3.1
                    res = regexp(value, '^[a-zA-Z]+([-+.a-zA-Z0-9])*$', 'once');
                    if isempty(res)
                        error(message('MATLAB:http:IllegalURIProperty', char(value), 'Scheme'));
                    end
                end
            end
            if strlength(value) == 0
                obj.Scheme = string.empty;
            else
                obj.Scheme = value;
            end
        end
        
        function obj = set.Host(obj, value)
            if ~isempty(value)
                value = strtrim(matlab.net.internal.getString(value, mfilename, 'Host'));
            end
            if strlength(value) == 0
                obj.Host = string.empty;
            else
                % We accept any string, because we just encode it.
                obj.Host = value;
            end
        end
        
        function obj = set.Port(obj, value)
            if isempty(value)
                port = [];
            else
                if ischar(value) || isstring(value)
                    value = matlab.net.internal.getString(value, mfilename, 'Port', true, 'numeric');
                    if strlength(value) == 0
                        port = [];
                    else
                        % This produces NaN if value can't be converted to a number
                        port = str2double(value); 
                    end
                else
                    port = value;
                end
                if ~isempty(port)
                    % If we get a URI with an invalid port, like
                    % "https://www.mathworks.com:foobar" we throw here.  Hopefully no
                    % server will ever send us a URI like this.  We could just not
                    % check this and store Port as a string, but that might conceal
                    % real user errors.
                    validateattributes(port, {'numeric','string'}, ...
                            {'integer', 'nonnegative', 'scalar', '<', 2^16}, mfilename, 'Port');
                end
            end
            obj.Port = port;
        end
        
        function obj = set.UserInfo(obj, value)
            if ~isempty(value)
                value = strtrim(matlab.net.internal.getString(value, mfilename, 'UserInfo'));
            end
            if strlength(value) == 0
                obj.UserInfo = string.empty;
            else
                % We accept any string, because we just encode it.
                obj.UserInfo = value;
            end
        end
        
        function obj = set.Path(obj, value)
            if isempty(value) && isnumeric(value) % check for [] exactly, not '' or string.empty
                obj.Path = [];
            elseif (isstring(value) && isscalar(value) && value.contains('/')) || ...
                    (ischar(value) && isvector(value) && any(value == '/')) 
                % Special-case a single string if it contains any '/' characters In this, a
                % leading/trailing slash will result in leading/trailing empty string. We
                % purposely want consecutive slashes to insert empty strings so that
                % EncodedPath returns the same result as the user set.
                obj.Path = strsplit(string(value), '/', 'CollapseDelimiters', false); 
            else
                % Not a single string with slashes or it's already a vector of strings; no
                % special meaning of slash
                obj.Path = matlab.net.internal.getStringVector(value, mfilename, 'Path');
            end
        end
        
        function obj = set.Fragment(obj, value)
            if ~isempty(value) 
                value = matlab.net.internal.getString(value, mfilename, 'Fragment');
            end
            if strlength(value) == 0
                obj.RealFragment = string.empty;
            else
                obj.RealFragment = value; 
            end
            obj.FragmentIsLiteral = false;
        end
        
        function str = get.EncodedQuery(obj)
            % QueryParameter.string stringifies the query
            str = string(obj.Query);
        end
        
        function obj = set.EncodedQuery(obj, arg)
            obj.Query = arg;
        end
        
        function tf = get.Absolute(obj)
            tf = ~isempty(obj.Scheme);
        end
        
        function str = get.EncodedPath(obj)
            import matlab.net.internal.urlencode
            persistent segmentNzNcDelims
            if isstring(obj.Path) && isempty(obj.Path)
                str = "/";
            else
                % If this is a relative path (i.e., doesn't begin with "/" and hence not
                % path-absolute or path-abempty) then we have to decide whether this is
                % path-rootless (begins with segment-nz) or path-noscheme (begins with
                % segment-nz-nc).  The only difference is that colons in the first segment of
                % path-noscheme must be encoded.
                %
                % path-absolute = "/" [ segment-nz *( "/" segment ) ] ; begins with "/" but not "//"
                % path-rootless = segment-nz *( "/" segment ) ]       ; beginns with segment
                % segment       = *pchar
                % segment-nz    = 1*pchar
                % pchar         = unreserved / pct-encoded / sub-delims / ":" / "@"
                % path-noscheme = segment-nz-nc [ *( "/" segment ) ]
                % segment-nz-nc = 1*(unreserved / pct-encoded / sub-delims / "@")
                % unreserved    = ALPHA / DIGIT / "-" / "." / "_" / "~"
                % pct-encoded   = "%" HEXDIG HEXDIG
                % sub-delims    = "!" / "$" / "&" / "'" / "(" / ")"
                %               / "*" / "+" / "," / ";" / "="
                %
                % All URIs (absolute or not) allow path-absolute.  In addition, an
                % absolute-URI allows path-rootless, and a relative-ref allows path-noscheme.
                % Therefore, if the URI is not Absolute, we must encode colons in the first
                % segment; otherwise we don't.
                if isempty(segmentNzNcDelims)
                    % Delimiters allowed in segment-nc-nz and pchar, in addition to
                    % unreserved and pct-encoded that urlencode allows by default
                    segmentNzNcDelims = [obj.SubDelims '@']; % sub-delims plus '@'
                end
                if obj.Absolute
                    path = urlencode(obj.Path, obj.Pchar);
                else
                    if ~isempty(obj.Path)
                        if strlength(obj.Path(1)) ~= 0
                            path = urlencode(obj.Path(1), segmentNzNcDelims);
                            if length(obj.Path) > 1
                                path = [path urlencode(obj.Path(2:end), obj.Pchar)];
                            end
                        else
                            path = urlencode(obj.Path, obj.Pchar);
                        end
                    else
                        path = string.empty;
                    end
                end
                str = strjoin(path, '/');
                % put a leading '/' in the EncodedPath if required as a separator from the
                % preceeding properties
                if obj.needsMakeAbsolutePath()
                    str = '/' + str;
                end
            end
        end
        
        function obj = set.EncodedPath(obj, path)
            if isempty(path) || (isstring(path) && strlength(path) == 0)
                obj.Path = path;
            else
                path = matlab.net.internal.getString(path, 'URI', 'EncodedPath');
                % first split and then decode the segments individually
                % The 2 argument gives us a row vector of strings
                obj.Path = matlab.net.internal.urldecode(split(path, '/', 2));
            end
        end
        
        function res = get.EncodedHost(obj)
            import matlab.net.internal.urlencode
            if ~isempty(obj.Host) && strlength(obj.Host) ~= 0
                % don't encode IPv6 addresses
                if isIPv6(obj.Host)
                    res = obj.Host;
                else
                    res = urlencode(obj.Host, obj.SubDelims); 
                end
            else
                res = "";
            end
        end
        
        function obj = set.EncodedHost(obj, host)
            if isequal(host, [])
                obj.Host = [];
            else
                obj.Host = matlab.net.internal.getString(path, 'URI', 'EncodedHost', true);
            end
        end
        
        function res = get.EncodedHostPort(obj)
            res = obj.EncodedHost;
            if ~isempty(obj.Port) 
                res = res + ':' + num2str(obj.Port);
            end
        end
        
        function res = get.EncodedAuthority(obj)
            res = obj.EncodedUserInfo + obj.EncodedHostPort;
        end
        
        function obj = set.EncodedAuthority(obj, value)
            authority = parseAuthority(matlab.net.internal.getString(value, mfilename, 'EncodedAuthority'));
            obj.UserInfo = matlab.net.internal.urldecode(authority.UserInfo);
            obj.Host = matlab.net.internal.urldecode(authority.Host);
            obj.Port = authority.Port; % this errors out if the port number is invalid
        end
        
        function str = get.EncodedURI(obj)
            str = string(obj);
        end
        
        function obj = set.EncodedURI(obj, value) %#ok<INUSL>
            % call our constructor to replace all the fields and re-parse the string
            obj = matlab.net.URI(value, 'literal');
        end
        
        function segs = get.Segments(obj)
            if isempty(obj.Host)
                hostSegs = string.empty;
            else
                % split at '.', but remove trailing empty segment if it's not the only one.
                % We want 'foo.bar.' to be equal to 'foo.bar'.  However '.' result in a host
                % of "", not string.empty.
                hostSegs = strsplit(obj.Host,'.');
                if length(hostSegs) > 1 && strlength(hostSegs(end)) == 0
                    hostSegs(end) = [];
                end
            end
            % Eliminate leading empty Path segment: treat '/foo/bar/' same as
            % 'foo/bar/'.  This means '/' turns into empty.
            path = obj.Path;
            if ~isempty(path) && strlength(path(1)) == 0
                path(1) = [];
            end
            % Assign segments right to left: Path, Port, Host, UserInfo and Scheme. Empty
            % trailing properties do not appear in segs.  The first one of the following
            % assignments to segs will turn it into a string vector.  Unassigned elements
            % are <missing>.
            if ~isempty(path)
                % Start of Path segments; 4 allows for Scheme, UserInfo, Port
                pathStart = 4 + length(hostSegs);
                segs(pathStart : pathStart+length(path)-1) = path;
            end
            if ~isempty(obj.Port)
                segs(3+length(hostSegs)) = string(obj.Port);
            end
            if ~isempty(hostSegs)
                segs(3 : 2+length(hostSegs)) = hostSegs;
            end
            if ~isempty(obj.UserInfo)
                segs(2) = obj.UserInfo;
            end
            if ~isempty(obj.Scheme)
                % canonicalize the scheme
                segs(1) = lower(obj.Scheme);
            end
            % emptyize <missing>
            segs(ismissing(segs)) = "";
        end  
        
        function res = get.EncodedUserInfo(obj)
            import matlab.net.internal.urlencode
            if isempty(obj.UserInfo) || strlength(obj.UserInfo) == 0
                res = "";
            else
                % In addition to the unreserved characters, userinfo doesn't need to
                % encode sub-delims and ':' according to RFC 3986, section 3.2.1.
                res = urlencode(obj.UserInfo, [obj.SubDelims ':']) + '@';
            end
        end
        
        function res = get.Fragment(obj)
            res = obj.RealFragment;
        end
        
        function res = string(obj)
        % string Encode and return the URI vector as a vector of strings
        %   STR = string(URI) returns the encoded URI, with each component
        %   percent-encoded as necessary.  Punctuation associated with each of the
        %   components appears in the result only if the component is nonempty.  For
        %   example, if the Path is empty, the '/' preceding it does not appear.
        
        %   TBD use foundation libraries IRI to encode, if possible, once we have an
        %   API to get there.
            import matlab.net.internal.urlencode
            if length(obj) > 1
                res = arrayfun(@string, obj, 'UniformOutput', false);
                res = [res{:}];
                return;
            elseif isempty(obj)
                res = [];
                return;
            end

            if isempty(obj.Fragment)
                fragment = [];
            else
                if obj.FragmentIsLiteral
                    fragment = '#' + obj.Fragment;
                else
                    fragment = '#' + urlencode(obj.Fragment, '/?'); 
                end
            end
            if isempty(obj.Query) 
                query = '';
            else
                query = '?' + string(obj.Query);
            end
            if isempty(obj.Path) && isnumeric(obj.Path)
                % Only [] creates empty path
                path = '';
            else
                % All others use EncodedPath
                path = obj.EncodedPath;
            end
            % string() used so that [] becomes empty string array
            scheme = string(obj.Scheme) + ':';
            ea = obj.EncodedAuthority;
            if strlength(ea) ~= 0
                ea = '//' + ea;
            end
            res = join([scheme ea path query fragment],'');
        end
        
        function str = char(obj)
        % char Encode and return the URI as a char vector
        %   If object is a vector of URIs, returns a cellstr.
        %
        % See also string
            str = string(obj);
            if length(str) > 1
                str = cellstr(str);
            else
                str = char(str);
            end
        end

        function obj = URI(varargin)
        % URI Create a URI.  
        %   obj = URI
        %   obj = URI(DESTINATION)
        %
        %   DESTINATION - A URI or string specifying a URI or portions of one, with
        %     the general syntax:
        %
        %         Scheme<a href=""></a>://UserInfo@Host:Port/Path?Query#Fragment
        %
        %     Each component becomes a property of this object with the names shown
        %     above, but with any associated punctuation omitted.  If you omit a
        %     component, you should omit its associated punctuation.  Note that
        %     'UserInfo@Host:Port' is recognized only if preceded by '//'.
        %
        %     Examples of valid DESTINATIONs:
        %
        %       All components:
        %         http<a href=""></a>://user:pwd@www.mathworks.com:8000/foo/bar?abc=def&foo=bar#xyz
        %       Host and Scheme:
        %         https://www.mathworks.com
        %       Host only:
        %         //www.mathworks.com
        %       Host and Path
        %         //www.mathworks.com/foo/bar
        %       Path only:
        %         /foo/bar
        %         one/two/three
        %       Host and Query only:
        %         //www.mathworks.com?abc=def&foo=bar
        %      
        %     Note you cannot send a message to a DESTINATION that does not contain a
        %     Scheme and Host.  This string will be parsed by looking for the
        %     associated punctuation to set the properties of this object. When this
        %     URI is used to send an HTTP message, the URI is reassembled from the
        %     properties back into a string and encoded.  The string and char methods
        %     produce this result.
        %
        %     If any component in the DESTINATION string contains a punctuation
        %     character that would normally be used to separate it from any following
        %     component, that parsing may be incorrect.  In that case you can either
        %     set that component explicitly by setting its corresponding property
        %     after creating the URI, or percent-encode the DESTINATION yourself and
        %     specify the 'literal' option (see below).  Percent-encoding means
        %     replacing each octet of the UTF-8 encoding of the character with a '%'
        %     followed by two hex digits representing the value of the octed.  For
        %     ASCII characters, this encoding is always one octet, so '?' would be
        %     encoded as '%3F'. The rules for what to encode vary for different parts
        %     of the URI: see RFC 3986, <a href="http://tools.ietf.org/html/rfc3986#section-2">section 2</a>.
        %
        %     For example, if the DESTINATION is '//www.mathworks.com/abc?def', this
        %     constructor would parse this as a Path of 'abc' and Query of 'def'
        %     because '?' indicates the start of the query.  But if you intended
        %     'abc?def' to be the Path you would percent-encode it yourself or
        %     construct the URI without the Path and set the Path property separately:
        %
        %          uri = matlab.net.URI('//www.mathworks.com/abc%3fdef','literal');
        %     or
        %          uri = matlab.net.URI('//www.mathworks.com');
        %          uri.Path = 'abc?def';
        %
        %     Characters following the first '?' or '#' in DESTINATION (i.e., the Query
        %     and Fragment) are assumed to be already-encoded, whether or not you
        %     specify 'literal', so they will be sent to the server as-is.  This means,
        %     for example, that a '+' in the Query will be interpreted by the server as
        %     a space instead of a literal '+'.  
        %
        %     If you do not specify 'literal', you should not encode any part of the
        %     DESTINATION string prior to the Query, because it will be erroneously
        %     re-encoded.  For example if you encode a ' ' as '%20' within the Path
        %     component, this constructor assumes that you intended to have a literal
        %     '%20' in your Path and will re-encode the '%' to %25', to result in
        %     '%2520'. However, the Query and Fragment portions of this string, if
        %     any, will never be encoded, so if you specify them within the
        %     DESTINATION you must encode the characters yourself.  To avoid the need
        %     to manually encode the query string, use one of the other constructors
        %     below or set the Query separately.
        %
        %     This constructor accepts almost all DESTINATION strings as valid URIs.
        %     The only error check is that the Port is a valid integer in the range
        %     0-65535 and that no illegal characters appear in the scheme.  Of course,
        %     other functions that accept URIs may enforce constraints on the URI
        %     contents.
        %
        %   obj = URI(DESTINATION, QUERY)
        %   obj = URI(DESTINATION, QueryName1, QueryValue1, ...)
        %   obj = URI(DESTINATION, QUERY, QueryName1, QueryValue1, ...)
        %   obj = URI(DESTINATION, QueryName1, QueryValue1, ..., FORMAT)
        %   obj = URI(DESTINATION, QUERY, QueryName1, QueryValue1, ..., FORMAT)
        %   obj = URI(___, 'literal') 
        %
        %   QUERY - A vector of matlab.net.QueryParameter, which will be
        %     used to set the Query property of this object.  When the URI is
        %     converted to a string, the encoded QueryParameters will be appended to
        %     any Query specified in the DESTINATION string.
        %
        %   QueryName, QueryValue - Names and values of additional query parameters.  
        %     Each pair will be used to construct a QueryParameter object to be added
        %     to the Query vector.  You should not encode any characters in these
        %     arguments.  See QueryParameter for more information.
        %
        %   FORMAT - A matlab.net.ArrayFormat following the last QueryValue that
        %     specifies the format of the output when an array appears in a
        %     QueryValue argument.  This does not affect the format of
        %     QueryParameters in the QUERY array.  See QueryParameter for allowed
        %     values.
        %
        %   obj = URI(___, 'literal') - An unpaired 'literal' at the end of
        %     the argument list indicates that the DESTINATION, if a string, and any
        %     QueryName and QueryValue arguments, are already encoded and should not be
        %     re-encoded when the URI is converted to a string.  Use this option if you
        %     have copied and pasted an already-encoded URI from elsewhere (e.g., a
        %     browser's address bar). When you read any of the properties of this URI
        %     directly, you will see the decoded version.  This option has no effect on
        %     QueryParameter arguments (which have their own optional 'literal'
        %     indicator).
        % 
        % See also string, char, QueryParameter, ArrayFormat,
        % matlab.net.http.RequestMessage.send
            if nargin ~= 0
                if nargin == 1 
                    arg = varargin{1};
                    if isempty(arg) && ~ischar(arg)
                        obj = matlab.net.URI.empty;
                        return
                    else
                        % Undocumented cases to support coercion from typed
                        % properties in other classes: arg can be URI array, cellstr
                        % or array of strings: return URI array.
                        if iscellstr(arg)
                            arg = string(arg);
                        else
                        end
                        if isstring(arg) && ~isscalar(arg)
                            obj = arrayfun(@matlab.net.URI, arg, 'UniformOutput', false);
                            obj = [obj{:}];
                            return
                        else
                        end
                        validateattributes(arg,{class(obj),'string','char'},{},mfilename);
                        if isa(arg, class(obj))
                            obj = arg;
                            return
                        else
                        end
                    end
                end
                % First arg, if any, must be string
                dest = matlab.net.internal.getString(varargin{1},mfilename,'parameter');
                % If last arg is 'literal', set flag and chop it off arg list
                literal = false;
                lastArg = varargin{end};
                % This test insures that 'literal' as the last argument is not a
                % QueryValue, by determining whether the number of args after
                % DESTINATION are even or odd, excluding QueryParameter or
                % ArrayFormat args.
                if (((ischar(lastArg) && isvector(lastArg)) || ...
                     (isstring(lastArg) && isscalar(lastArg))) && ...
                     strcmpi(lastArg, 'literal')) && ...
                   (nargin <=2 || ...
                     (mod(nargin,2) == ...
                       xor(isa(varargin{2}, 'matlab.net.QueryParameter'), ...
                           isa(varargin{end-1}, 'matlab.net.ArrayFormat'))))
                   literal = true;
                   varargin(end) = [];
                else
                end    
                obj = obj.parse(dest, literal);
                % determine first QueryName, if any
                if length(varargin) > 1
                    if isa(varargin{2}, 'matlab.net.QueryParameter') 
                        obj.Query = [obj.Query varargin{2}];
                        first = 3;
                    else
                        first = 2;
                    end
                    % This passes along all the remaining arguments, including any
                    % ArrayFormat at the end
                    if first <= length(varargin)
                        if literal
                            obj.Query = [obj.Query matlab.net.QueryParameter(varargin{first:end}, 'literal')];
                        else
                            obj.Query = [obj.Query matlab.net.QueryParameter(varargin{first:end})];
                        end
                    end
                else
                end
            end
        end
        
        function tf = eq(obj, other)
        % == compare URIs for equality
        %   eq(OBJ, URIs)  uses the same rules as numeric array comparisons for scalar
        %   expansion, returning an array if either argument is an array.  Returns []
        %   if one argument is a scalar and the other is [].
        %
        %   Two URIs are considered equal if they refer to the same resource.  This
        %   means all properties have to be equal, where an empty string value or Path
        %   vector is considered equal to [].
        %
        %   Also, a single empty trailing Path segment is ignored, and Path
        %   comparisons are based on EncodedPath.  For example:
        %     URI('//www.mathworks.com/')      == URI('//www.mathworks.com')
        %     URI('//mathworks.com/foo/bar/')  == URI('//mathworks.com/foo/bar')
        %     URI('//mathworks.com/foo/bar//') ~= URI('//mathworks.com/foo/bar')
        %     URI('//mathworks.com/foo bar')   == URI('//mathworks.com/foo%20bar','literal')

            % Do size check before class check as that will error out with a good message
            % when number of dimensions disagree
            if size(obj) == size(other) 
                if ~strcmp(class(obj),class(other))
                    error(message('MATLAB:http:MustBeSameClass'));
                else
                end
                if isscalar(obj)
                    % vanilla scalar compare
                    tf = isequal(obj.canonicalize(), other.canonicalize());
                else
                    % Both args not scalars but sizes same, return array
                    tf = arrayfun(@(a,b) a == b, obj, other);
                end
            elseif isscalar(other)
                % obj is array or []; scalar expansion of other
                % returns [] if obj is []
                tf = arrayfun(@(a) a == other, obj);
            elseif isscalar(obj)
                % other is array or []; scalar expansion of obj
                % returns [] if other is []
                tf = arrayfun(@(b) obj == b, other);
            else
                % neither is scalar or [] and dimension sizes differ
                error(message('MATLAB:dimagree'));
            end
        end
    end
    
    methods (Access= {?matlab.net.http.Credentials, ...
                      ?matlab.net.http.internal.CredentialInfo, ?tHTTPURIUnit}, ...
             Hidden)
        function tf = le(obj, uri)
        % <= return true if this URI is equal to or a subset of uri, matching
        %   properties and whole segments left to right.  If this obj has a trailing
        %   '/' in its path, then it is not considered a subset of an identical uri
        %   without that trailing slash because it has one more path segment).
        %   However ignore the trailing slash if the length of obj.Path is less than
        %   or equal to the length uri.Path.  This means that 'foo/bar/' is not a
        %   subset of 'foo/bar' (the first one has more segments), but 'foo/' is
        %   because we ignore the final /.
        %
        %   This function is used to determine whether credentials which apply to obj
        %   can be used for uri as well.

            % Inefficient, but simple
            objSegs = obj.Segments;
            uriSegs = uri.Segments;
            if length(objSegs) <= length(uriSegs)
                if strlength(objSegs(end)) == 0
                    objSegs(end) = [];
                end
                tf = isequal(objSegs, uriSegs(1:length(objSegs)));
            else
                tf = false;
            end
        end
        
        function tf = ge(obj, uri)
            tf = uri <= obj;
        end
        
        function uri = trimAtPath(obj)
        % Return this URI with Path and everything after it removed
            uri = obj;
            uri.Path = [];
            uri.Query = [];
            uri.Fragment = [];
        end
        
        function len = matchLength(obj, uri)
        % matchLength returns the length of match of this URI with uri by counting
        % matching "components" from left to right, where component 1 includes all of
        % the Scheme, UserInfo, Host and Port, and the remaining components are
        % segments of the Path. Therefore len-1 is the number of matching path
        % segments, where the root does not count as a segment.
        %
        % It uses matchPath() to count matching path segments.  
        %
        % If obj is a vector, returns vector of lengths.
        %
        % This function is designed primarily to satisfy the recommendation for
        % matching URIs in section 2 ("all paths at or deeper" for Basic) and section
        % 3.2.1 ("any URI that has a URI in this list as a prefix" for Digest domain)
        % of RFC 2617.  
       
            len(length(obj)) = 0;
            this = obj.canonicalize();
            uri = uri.canonicalize();
            for i = 1 : length(obj)
                if isequal(this.Scheme, uri.Scheme) && ...
                   isequal(this.UserInfo, uri.UserInfo) && ...
                   isequal(this.Host, uri.Host) && ...
                   isequal(this.Port, uri.Port)
                    len(i) = 1 + obj(i).matchPath(uri);
                else
                    len(i) = 0;
                end
            end
        end
        
        function len = matchPath(obj, uri)
        % matchPath compares segments of this URI.Path with uri.Path, left to right.
        %   len    number of matching segments
        % When comparing the paths, an empty trailing segment (i.e., a lone '/' at the
        % end of the stringified version) is ignored.  If either Path is the root,
        % string.empty or [], returns 0, so that all empty and root paths are
        % equivalent.  This means that matching "/" to "/", or "/" to "/foo", will
        % return 0, which makes sense when counting matching segments in a full URI.
            len = matchCount(uri.canonicalizePath(), obj.canonicalizePath());
        end
        
        function [len, objLen, uriLen] = matchHost(obj, uri, reverse)
        % matchHost compares segments of URI.Host with uri.Host, left to right
        %  len     number of matching segments
        %  reverse if true, match right to left
        %  objLen  number of segments in obj.Host
        %  uriLen  nubmer of segments in uri.Host
        
            % empty needs special test because strsplit returns '' for empty, which
            % string converts to vector of 1 instead of vector of 0
            if isempty(obj.Host)
                oh = string.empty(1,0);
            else
                oh = string(strsplit(char(obj.Host), '.')); % TBD string 
            end
            if isempty(uri.Host)
                uh = string.empty(1,0);
            else
                uh = string(strsplit(char(uri.Host), '.')); % TBD string 
            end
            if reverse
                len = matchCount(flip(oh), flip(uh));
            else
                len = matchCount(oh, uh);
            end
            if nargin > 1
                objLen = length(oh);
            end
            if isempty(uri.Host)
                uriLen = length(uh);
            end
        end
        
        function uri = resolve(obj, uri)
        % resolve returns the uri resolved against this URI.
        %   If uri has a Scheme, the uri is returned.  Otherwise this returns uri
        %   with all empty properties of uri, except Query and Fragment, replaced by
        %   values from this URI.  
            if isempty(uri.Scheme)
                uri.Scheme = obj.Scheme;
                if isempty(uri.UserInfo), uri.UserInfo = obj.UserInfo; end
                if isempty(uri.Host),     uri.Host = obj.Host;         end
                if isempty(uri.Port),     uri.Port = obj.Port;         end
            end
        end
    end
    
    methods (Static, Access={?matlab.net.http.field.HostField, ...
            ?matlab.net.http.Credentials, ?matlab.net.http.HTTPOptions,...
            ?matlab.net.http.RequestMessage})
        function uri = assumeHost(str)
        % Returns a URI constructed from a string, similar to the URI constructor, but
        % if str does not begin with 'scheme://' or '//', then treat it as if it begins
        % with '//'.  This permits a string such as 'host/path/' to be
        % interpreted as '//host/path', allowing you to write 'www.foo.com' as a
        % shortcut for '//www.foo.com'.
        %
        % Use this function in contexts where a Host is always required in a URI
        % (i.e., it is never just a Path).  It is up to the caller to error out if the
        % returned uri doesn't contain a Host.
        %
        % If str is empty the result is an empty URI.
            str = strtrim(string(str));
            % This check for leading scheme uses same regexp that parse() uses to detect
            % Scheme.  Require the '//' after the scheme: because, if given 'foo:25' we
            % don't want to misintepret 'foo' as a scheme.
            res = regexp(str, '^([^:/?#]*:)?//','once');
            if isempty(res)
                % doesn't begin with '//' or 'scheme://'
                str = '//' + str;
            end
            uri = matlab.net.URI(str);
        end
    end
    
    methods (Access=private)
        function obj = parse(obj, dest, literal)
            % Parse dest (string or char vector) as a URI.  If literal specified,
            % treat it as an unambiguous already-encoded URI.  Otherwise parsing is
            % based on delimiters, which could be ambiguous if any of the
            % the components is supposed to contain a delimiter.  Any query portion of the
            % URI is assumed to be literal.
            
            % This regexp is for a URI reference from RFC 3986, Appendix B:
            %   ^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?
            %    12            3  4          5       6  7        8 9
            % where scheme = $2
            %    authority = $4
            %    path      = $5
            %    query     = $7
            %    fragment  = $9
            % Since we can't capture inner parens, we use lookaround assertions to test
            % for required punctuation, and then discard the lookaround parts.
            dest = strtrim(dest);
            if strlength(dest) ~= 0
                parts = regexp(strtrim(dest), [... 
                    '^(?<Scheme>([^:/?#]+)(?=:))?:?' ...
                     '(//)?(?<Authority>(?<=//)([^/?#]*))?' ...
                     '(?<Path>[^?#]*)' ...
                     '\??(?<Query>(?<=\?)([^#]*))?' ...
                     '#?(?<Fragment>(?<=#)(.*))?$'], 'names', 'once');
                if isempty(parts)
                    error(message('MATLAB:http:BadURI',char(dest)));
                elseif literal
                    % We want to store the parts in decoded form.  If we re-encode them, we should
                    % get back what the user entered.  To do this, we need to decode each part of
                    % a component separately so that delimiters such as @, /, &, = are
                    % distinguishable from their %-encoded equivalents.  For example a Path of
                    % 'abc%2Fdef/ghi' must become 2 path segments of 'abc/def' and 'ghi', not
                    % three segments.
                    import matlab.net.internal.urldecode
                    obj.Scheme = urldecode(parts.Scheme);
                    authority = parseAuthority(parts.Authority);
                    if ~isempty(authority)
                        authority = structfun(@urldecode, authority, 'UniformOutput', false);
                        obj.UserInfo = authority.UserInfo;
                        obj.Host = authority.Host;
                        obj.Port = authority.Port;
                    end
                    % urldecode each path segment separately
                    if strlength(parts.Path) ~= 0
                        if strcmp(parts.Path,'/')
                            % See comment below about parts.Path
                            obj.Path = string.empty;
                        else
                            path = split(parts.Path,'/')';
                            obj.Path = string(arrayfun(@urldecode, path, 'UniformOutput', false));
                        end
                    end
                else
                    obj.Scheme = parts.Scheme;
                    if strlength(parts.Authority) ~= 0
                        % Authority needs more parsing.  We don't want to simply set EncodedAuthority
                        % because its set function assumes the value is encoded, whereas we expect to
                        % have decoded parts.
                        authority = parseAuthority(parts.Authority);
                        if strlength(authority.UserInfo) ~= 0
                            obj.UserInfo = authority.UserInfo;
                        end
                        obj.Host = authority.Host;
                        obj.Port = authority.Port;
                    end
                    if strlength(parts.Path) ~= 0
                        % Path gets set only if there is at least one character in it
                        % For simplicity, we set Path to string.empty if it contains just a slash.
                        % Otherwise setting it to '/' would store ["" ""].  This is has exactly the
                        % same effect when Path or the URI are stringified, but string.empty is just
                        % simpler to look at and perhaps less surprising to the user.
                        if parts.Path == '/'
                            obj.Path = string.empty;
                        else
                            obj.Path = parts.Path;
                        end
                    end
                end
                % Query is always treated as literal.  QueryParameter already handles
                % pre-encoded query, but we need to make sure that, when encoded later, it
                % returns the same string, so need to specify 'literal'. Otherwise, for example,
                % a '%2F' input would be turned into '/'. Need to supply an ArrayFormat argument
                % to be sure that 'literal' is interpreted as a flag and not a value, in case
                % parts.Query is a string without an = in it.
                import matlab.net.*
                obj.Query = QueryParameter(parts.Query, ArrayFormat.csv, 'literal');
                if strlength(parts.Fragment) ~= 0
                    obj.Fragment = parts.Fragment;
                    obj.FragmentIsLiteral = true;
                end
            end
        end
        
        function tf = hasSchemeOrAuthority(obj)
        % Return true if the URI has nonempty properties prior to the Path.
           tf = (~isempty(obj.Host) || ~isempty(obj.Scheme) || ...
                 ~isempty(obj.UserInfo) || ~isempty(obj.Port));
        end

        function tf = needsMakeAbsolutePath(obj)
        % Return true if the Path should be forced to absolute (by adding a '/' to the
        % front of it) because the URI has nonempty properties prior to the Path, and
        % the Path is not already absolute (i.e., does not begin with an empty segment
        % "").  A empty path of [] always returns false but string.empty may return
        % true.
            % If ~isstring, then we know it must be [], since that's the only nonempty
            % type we allow for the Path
            % First 2 lines determine path is string.empty or relative.
            tf = (isstring(obj.Path) && ...
                  (isempty(obj.Path) || strlength(obj.Path(1)) ~= 0)) && ...
                 obj.hasSchemeOrAuthority;
        end
              
        function obj = canonicalize(obj)
        % Return a canonicalized URI, one with host ahd scheme lower-cased and path
        % canonicalized.  Used to make comparisons predictable.  
            obj.Scheme = lower(obj.Scheme);
            obj.Host = lower(obj.Host);
            obj.Path = obj.canonicalizePath();
        end
    
        function path = canonicalizePath(obj)
        % Canonicalize the path so that semantically equivalent paths would compare
        % equal using isequal.  If hasSchemeOrAuthority a relative path should compare
        % equal to an absolute one if all segments are the same, so root and empty
        % paths are equivalent.  But if ~hasSchemeOrAuthority, an empty path is not
        % equal to a root path.
        %   1. Eliminate any empty trailing path component (corresponding to a
        %      trailing "/" in the input path). 
        %   2. If hasSchemeOrAuthority, add a leading "" to the Path if it is
        %      relative (i.e., nonempty and doesn't begin with ""), thus making it
        %      absolute.
        %   3. If hasSchemeOrAuthority, convert the two variations of empty path 
        %      ("" or []) to string.empty, thus making it a root path; otherwise
        %      convert them to [] to indicate empty.
        %   4. Convert the two variations of root path (["" ""] or string.empty) to 
        %      string.empty.  
        % If hasSchemOrAuthority is set, above means that all root and empty paths
        % become root paths (string.empty).

            % root means string.empty or ["" ""] 
            path = obj.Path;
            isRoot = isequal(path, string.empty) || isequal(path, ["" ""]);
            % empty means "" or []
            isEmpty = isequal(path, "") || isequal(path, []);
            if ~isempty(path) && length(path) > 1 && strlength(path(end)) == 0
                % ends in "", so remove it
                path(end) = [];
            end
            if obj.hasSchemeOrAuthority() 
                % make absolute
                if isEmpty || isRoot
                    % all empty or root paths become root path
                    path = string.empty;
                elseif strlength(path) ~= 0
                    % relative paths become absolute
                    path = ["" path];          
                end
            else
                % Not making absolute; root becomes string.empty and empty becomes []
                if isRoot
                    path = string.empty;
                elseif isEmpty
                    path = [];
                end
            end
        end
    end
end

function len = matchCount(a,b)
% Given 2 vectors of possibly different length, return the number of contiguous
% matching elements starting from the first using ~= comparison.  Returns 0 if either
% is empty or no matches.
    last = min([length(a) length(b)]);
    if last == 0
        len = 0;
    else
        % find first nonmatching element
        matchLen = find(a(1:last) ~= b(1:last), 1);
        if isempty(matchLen)
            len = last;
        else
            len = matchLen - 1;
        end
    end
end

function authority = parseAuthority(value)
% Return struct, splitting authority string into UserInfo@Host:Port
    % In this expression, the Host extends from the character after the first @ or
    % beginning of string to the character before the last colon followed by 0 or
    % more digits, or end of string.
    authority = regexp(value, ...
          '^(?<UserInfo>[^@]*(?=@))?@?(?<Host>.*?)?:?(?<Port>(?<=:)\d*)?$', ...
          'names', 'once');
end

function tf = isIPv6(host)
    tf = strlength(host) > 2 && host.startsWith('[') && host.endsWith(']');
end

