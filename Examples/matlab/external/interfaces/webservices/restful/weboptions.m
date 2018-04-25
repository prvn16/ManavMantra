%WEBOPTIONS Specify parameters for RESTful web service
%
%   Syntax
%   ------
%   OPTIONS = WEBOPTIONS
%   OPTIONS = WEBOPTIONS(Name,Value)
%
%   Description
%   -----------
%   OPTIONS = WEBOPTIONS constructs a default WEBOPTIONS object to specify
%   parameters for obtaining data from a web server.
%
%   OPTIONS = WEBOPTIONS(Name,Value) returns OPTIONS with the named
%   parameters initialized with the specified values. For each Name that
%   matches a property name of the WEBOPTIONS class (CharacterEncoding,
%   UserAgent, Timeout, Username, Password, KeyName, KeyValue, ContentType,
%   or ContentReader) the corresponding Value is copied to the property.
%   The size of OPTIONS is scalar. WEBOPTIONS issues an error if Name does
%   not match a property name.
%
%   WEBOPTIONS properties:
%      CharacterEncoding - Character encoding
%      UserAgent - User agent identification
%      Timeout - Connection timeout
%      Username - User identifier
%      Password - User authentication password
%      KeyName - Name of key
%      KeyValue - Value of key
%      HeaderFields - Names and values of additional header fields
%      ContentType - Type of content
%      ContentReader - Content reader   
%      MediaType - Media representation of data to send
%      RequestMethod - Name of HTTP request method
%      Arrayformat - format to use when QueryValue is an array
%      CertificateFilename - filename of root certificates in PEM format
%
%
%   % Example 1
%   % ---------
%   % Construct a default WEBOPTIONS object and set Timeout value to
%   % Inf to indicate no timeout.
%   options = weboptions;
%   options.Timeout = Inf
%
%   % Example 2
%   % ---------
%   % Construct a WEBOPTIONS object and set Username and Password.
%   % When displaying the object, Password is displayed with '*' values.
%   % For added security, use inputdlg to prompt for the values.
%   values = inputdlg({'Username:', 'Password:'});
%   options = weboptions('Username',values{1},'Password',values{2})
%
%   % Example 3
%   % ---------
%   % Construct a WEBOPTIONS object and set the value of ContentReader 
%   % to a function handle for the importdata function. This may be 
%   % helpful when reading certain text or CSV files.
%   options = weboptions('ContentReader', @importdata)
%
%   See also WEBREAD, WEBWRITE, WEBSAVE

% Copyright 2014-2017 The MathWorks, Inc.

classdef weboptions <  matlab.mixin.CustomDisplay
    properties (AbortSet)
        %CharacterEncoding Character encoding
        %
        %   CharacterEncoding is a string indicating the desired character
        %   encoding of text content. Common values include 'US-ASCII',
        %   'UTF-8', 'latin1', 'Shift_JIS', or 'ISO-8859-1'. The default
        %   value is 'auto' indicating encoding is determined
        %   automatically.
        CharacterEncoding = 'auto'
        
        %UserAgent User agent identification
        %
        %   UserAgent is a string or character vector indicating the client user agent
        %   identification. The default value is ['MATLAB ' version].
        UserAgent = ['MATLAB ' version]
        
        %Timeout Connection timeout
        %
        %   Timeout is a positive numeric scalar indicating the connection
        %   timeout duration in seconds. The Timeout value determines when
        %   the function errors rather than continuing to wait for the
        %   server to respond or send data. Set the value to Inf to disable
        %   timeouts. The default value is 5 seconds.
        Timeout = 5
        
        %Username User identifier
        %
        %   Username is a string or character vector identifying the user. If you set
        %   the Username property value, you should also set the Password property
        %   value. Basic HTTP authentication is utilized. The default value is the
        %   empty string.
        Username = ''
        
        %Password User authentication password
        %
        %   Password is a string or character vector indicating the user
        %   authentication password. If you set the Password property value, you
        %   should also set the Username property value. If you display the object
        %   with the Password property set, the value is displayed with values of '*'.
        %   The actual value is obtained when you get the property's value. Basic HTTP
        %   authentication is utilized. The default value is the empty string.
        Password = ''
        
        %KeyName Name of key
        %
        %   KeyName is a string or character vector indicating an additional name,
        %   such as a web service API key name, to add to the HTTP request header. If
        %   you set the KeyName property value, you should also set the KeyValue
        %   property value. The default value is the empty string.
        %
        %   To add more than one request header, use the HeaderFields property.
        %
        % See also KeyValue, HeaderName
        KeyName = ''
        
        %KeyValue Value of key
        %
        %   KeyValue is a string, character vector, numeric, or logical indicating the
        %   value of the key, specified by KeyName, to add to the HTTP request header.
        %   If you set the KeyValue property value, you should also set the KeyName
        %   property value. The default value is the empty string.
        %
        % See also KeyValue
        KeyValue = ''
        
        %ContentType Type of content to return
        %
        %   ContentType is a string or character vector indicating the type of MATLAB
        %   data to return. The type specified must be consistent with the content type
        %   returned by the server. Permissible values are listed in the table below:
        %
        %   Value      Description
        %   -----      -----------
        %   'text'     character vector for text/plain, text/html, text/xml, and
        %              application/xml content
        %
        %   'image'    numeric or logical matrix for image/format content
        %
        %   'audio'    numeric matrix for audio/format content
        %
        %   'binary'   uint8 column vector for binary (non-string) content
        %
        %   'table'    scalar table object for spreadsheet and CSV 
        %              (text/csv) content
        %
        %   'json'     char, numeric, logical, structure, or cell array, 
        %              for application/json content
        %
        %   'xmldom'   Java Document Object Model (DOM) node for text/xml
        %              or application/xml content. If not specified, XML
        %              content is returned as a string.
        %
        %   'raw'      Dependent on content type: 'text', 'xmldom', and
        %              'json' content are returned as a char column vector,
        %              all others are returned as a uint8 column vector.
        %
        %   'auto'     Automatically determined based on content type specified 
        %              by the server, and is the default value.
        ContentType = 'auto'
        
        %ContentReader Content reader 
        %
        %   ContentReader is a function handle used to read content. When
        %   used with the function webread, the data is downloaded to a
        %   temporary file and read using the specified function. The
        %   temporary file is automatically deleted after the data is read
        %   from the file. The function is passed the temporary filename as
        %   the first argument. You may be able to use an anonymous
        %   function to adapt a file-reading function that requires
        %   additional input arguments. ContentType is ignored when using
        %   ContentReader.
        ContentReader = []
        
        %MediaType Media representation of data to send
        %
        %   MediaType is a string or character vector that specifies the type of data
        %   WEBWRITE sends to the web service. It specifies the content type that MATLAB
        %   specifies to the server, and it controls how the DATA argument to WEBWRITE
        %   (if specified) is converted.
        %
        %   The default value is 'auto' that indicates MATLAB chooses the type based on
        %   the input to WEBWRITE. If using PostName/PostValue pairs, MATLAB uses
        %   'application/x-www-form-urlencoded' to send the pairs. If using a DATA
        %   argument that is a scalar string or character vector, MATLAB assumes it is a
        %   form-encoded string and sends it as-is using
        %   'application/x-www-form-urlencoded'. If the DATA is anything else, MATLAB
        %   converts it to JSON using JSONENCODE and uses the content type
        %   'application/json'.
        %
        %   If you specify a MediaType containing 'json' or 'javascript', and DATA is a
        %   character vector, it is sent as-is. All other types, including scalar
        %   strings, are converted using JSONENCODE.
        %
        %   If you specify 'application/x-www-form-urlencoded', PostName/PostValue pairs
        %   are sent form-encoded. DATA, if present, must be a string or character
        %   vector to be sent as-is.
        %
        %   If you specify a MediaType that contains 'xml', and DATA is a Document
        %   Object Model object (a Java org.apache.xerces.dom.DocumentImpl), it is
        %   converted to XML.  DATA, if present, must be a string or character vector
        %   to be sent as-is.
        %
        %   If you specify any other MediaType, and DATA is a string or character
        %   vector, it will be sent as-is.
        %
        %   Note that PostName/PostValue pairs are accepted only for MediaTypes 'auto'
        %   and 'application/x-www-form-urlencoded', and character vectors are always
        %   sent as-is regardless of the MediaType.
        %   
        %   For a complete list of values, refer to <a href="matlab:web('http://www.iana.org/assignments/media-types/media-types.xhtml')">Internet media types.</a> 
        %   The value is not validated against this list of media types.
        %
        %   You may also specify a media type using a matlab.net.http.MediaType
        %   object.  In this case only the Type and Subtype are used.
        %
        %   See also matlab.net.http.MediaType, WEBWRITE, JSONENCODE
        MediaType = 'auto'
        
        %RequestMethod Name of HTTP request method
        %
        %   RequestMethod is a case-insensitive string or character vector indicating
        %   the HTTP method of the request. Permissible values are:
        %      'get'     Suitable for WEBREAD or WEBSAVE
        %      'post'    Suitable for WEBREAD, WEBWRITE or WEBSAVE
        %      'put'     Suitable for WEBREAD, WEBWRITE or WEBSAVE
        %      'delete'  Suitable for WEBREAD, WEBWRITE or WEBSAVE
        %      'patch'   Suitable for WEBREAD, WEBWRITE or WEBSAVE
        %      'auto'    (default) Determine method automatically: WEBREAD and WEBSAVE
        %                use GET and WEBWRITE uses POST.
        %   The string can be abbreviated.
        %
        %   The method may also be specified using a matlab.net.http.RequestMethod
        %   enumeration.
		%
        %   Selection of the request method has no effect on where query parameters are
        %   placed: WEBREAD and WEBSAVE place parameters in the URL, while WEBWRITE
        %   places them in the body of the message.
        %
        %   See also matlab.net.http.RequestMethod, WEBREAD, WEBWRITE, WEBSAVE
        RequestMethod = 'auto'

        %ArrayFormat Method used to convert array query values
        %
        %   ArrayFormat controls the format used to convert query values that 
        %   represent multiple values (e.g., vectors or cell arrays) in the URL.  
        %   It is a string or character vector with one of the following values: 
        %
        %    ArrayFormat  Example where queryName='parm' and queryValue=[1,2,3]
        %     'csv'         parm=1,2,3             (default)
        %     'json'        parm=[1,2,3]
        %     'repeating'   parm=1&parm=2&parm=3
        %     'php'         parm[]=1&parm[]=2&parm[]=3
        %
        %   The format may also be specified as a matlab.net.ArrayFormat enumeration.
        %
        %   A query value is considered to contain multiple values if it is:
        %     a non-scalar number, logical or datetime (each element is a value)
        %     a character matrix with more than one row (each row is a string value)
        %     a cell vector (each element is a value)
        %   Except for character matrices, arrays of more than one dimension are
        %   not supported.  In cell arrays, each element must be a scalar or
        %   character vector.
        %
        %   See also matlab.net.ArrayFormat
        ArrayFormat = 'csv'
        
        %HeaderFields Names and values of additional header fields
        %
        %   HeaderFields is an m-by-2 cell array of character vectors or m-by-2 string
        %   matrix specifying the names and values of additional header fields to add
        %   to the HTTP request header.  HeaderFields{i,1} is the name of a field and
        %   HeaderFields{i,2} is its value.  Alternatively, you can specify a vector
        %   of matlab.net.http.HeaderField objects.
        %
        %   These fields override any fields whose names are a case-insensitive match to
        %   fields automatically added to the request, or which are added as a result of
        %   other options.  If the value of a field is empty or an empty string, the
        %   field will be removed from the request.
        %   
        %   Some fields whose value is necessary to successfully send a request, such
        %   as Connection and Content-Length, cannot be overridden.
        %
        %   See also webread, webwrite, websave, matlab.net.http.HeaderField
        HeaderFields = []
        
        %CertificateFilename File name of root certificates in PEM format
        %
        %   CertificateFilename is a character vector or string denoting the location
        %   of a file containing certificates in PEM format.  The location must be in
        %   the current directory, in a directory on the MATLAB path, or a full or
        %   relative path to a file.  If this property is set and you request an HTTPS
        %   connection, the certificate from the server is validated against the
        %   certification authority certificates in the specified PEM file.  This is
        %   used by standard https mechanisms to validate the signature on the
        %   server's certificate and the entire certificate chain.  A connection is
        %   not allowed if verification fails.
        %
        %   By default, the property value is set to the certificate file that ships
        %   with MATLAB, located at:
        %       fullfile(matlabroot,'sys','certificates','ca','rootcerts.pem')
        %   If you need additional certificates, you can copy this file and add your
        %   certificates to it.  MATLAB provides no tools for managing certificates or
        %   certificate files, but there are various third party tools that can do so
        %   using PEM files.  PEM files are ASCII files and can be simply
        %   concatenated.  Since security of HTTPS connections depend on integrity of
        %   this file, you should protect it appropriately.
        %
        %   If you specify the value 'default' the above certificate filename will be
        %   used.
        %
        %   If set to empty, the only verification done for the server certificate is
        %   that the domain matches the host name of the server and that it has not
        %   expired: the signature is not validated.
        %
        %   Set this to empty only if you are having trouble establishing a connection
        %   due to a missing or expired certificate in the default PEM file and you do
        %   not have any alternative certificates.
        CertificateFilename = weboptions.DefaultCertificateFilename
    end
    
    properties (Hidden)
        Debug = false;
    end
    
    properties (Constant, Access=private)
        DefaultCertificateFilename = fullfile(matlabroot,'sys','certificates','ca','rootcerts.pem');
    end
    
    methods
        function options = weboptions(varargin)
        %WEBOPTIONS constructor
        
            if nargin ~= 0
                % Parse the inputs from varargin, and return a structure.
                inputs = parseInputs(options, varargin);
                
                % Set the input values.
                options = setInputs(options, inputs);                
            end
        end
        
        %----------------- set methods ------------------------------------
 
        function options = set.CharacterEncoding(options, value)
        % Validate and set CharacterEncoding.
            defaultValue = 'auto';
            if ~strcmp(value, defaultValue)
                options.CharacterEncoding = validateCharacterEncoding(value);
            else
                options.CharacterEncoding = defaultValue;
            end
        end
        
        function options = set.RequestMethod(options, value)
        % Validate and set RequestMethod.
            rType = 'matlab.net.http.RequestMethod';
            if isa(value, rType)
                value = char(value);
            else
                validateattributes(value, {'char' 'string' rType}, {}, mfilename, 'RequestMethod');
            end
            options.RequestMethod = validatestring(value, ...
                {'auto','get','post','put','delete','patch'}, mfilename, 'RequestMethod');
            options.RequestMethod = lower(char(value));
        end
        
        %------------------------------------------------------------------
        
        function options = set.UserAgent(options, value)
        % Validate and set UserAgent
            options.UserAgent = validateStringValue(value, 'UserAgent');
        end
        
        %------------------------------------------------------------------
        
        function options = set.Timeout(options, value)
        % Validate and set Timeout.
            validateattributes(value, {'numeric'}, ...
                {'positive', 'scalar', 'nonnan'}, mfilename, 'Timeout');
            options.Timeout = value;
        end
        
        %------------------------------------------------------------------
        
        function options = set.Username(options, value)
        % Validate and set Username.
            options.Username = validateStringValue(value, 'Username');
        end
        
        %------------------------------------------------------------------
        
        function options = set.Password(options, value)
        % Validate and set Password.
            options.Password = validateStringValue(value, 'Password');
        end
        
        %------------------------------------------------------------------
        
        function options = set.KeyName(options, value)
        % Validate and set KeyName.
            options.KeyName = validateStringValue(value, 'KeyName');
        end
        
        %------------------------------------------------------------------
        
        function options = set.KeyValue(options, value)
        % Validate and set KeyValue.
            if ~isempty(value)
                if isstring(value)
                    value = char(value);
                end
                validateattributes(value, {'string', 'char', 'numeric', 'logical'}, ...
                    {}, mfilename, 'KeyValue')
                value = reshape(value, 1, numel(value));
                options.KeyValue = value;
            else
                options.KeyValue = '';
            end
        end
        
        %------------------------------------------------------------------
        
        function options = set.HeaderFields(options, value)
            hfType = 'matlab.net.http.HeaderField';
            if isa(value, hfType)
                % if vector of HeaderField, extract Name and Value to make Nx2 string matrix
                validateattributes(value, {hfType}, {'vector'}, mfilename, 'HeaderFields');
                for i = numel(value) : -1 : 1
                    val = value(i).Value;
                    if isempty(val)
                        val = "";
                    end
                    res(i,2) = val;
                    name = value(i).Name;
                    if isempty(name) || name == ""
                        error(message('MATLAB:http:EmptyNameForField',val));
                    end
                    res(i,1) = name;
                end
                value = res;
            else
                validateStringMatrix(value);
            end
            options.HeaderFields = value;
        end
                
        %------------------------------------------------------------------
        
        function options = set.ContentType(options, value)
        % Validate and set ContentType.
            value = validatestring(value, ...
                {'text', 'image', 'binary', 'table', 'audio', 'json', ...
                 'xmldom', 'raw', 'auto'}, mfilename, 'ContentType');
            options.ContentType = value;
        end
        
        %------------------------------------------------------------------
        
        function options = set.ContentReader(options, value)
        % Validate and set ContentReader.
            if ~isempty(value)
                validateattributes(value, {'function_handle'}, {'scalar'}, ...
                    mfilename, 'ContentReader')
                options.ContentReader = value;
            else
                options.ContentReader = [];
            end
        end
        
        %------------------------------------------------------------------
        
        function options = set.MediaType(options, value)
        % Validate and set MediaType
            mediaType = 'matlab.net.http.MediaType';
            if ~isa(value, mediaType)
                try
                    % parse string using MediaType; string.empty arg says only allow
                    % type/subtype without parameters
                    value = matlab.net.http.MediaType(value, string.empty);
                catch e
                    % Doesn't parse as MediaType.  Issue error if wrong type.
                    validateattributes(value, {'string' 'char' mediaType}, ...
                                            {'scalartext','nonempty'}, mfilename, 'MediaType');
                    if strcmpi(value,'auto')
                        % allow 'auto' which is an illegal MediaType
                        options.MediaType = char(lower(value));
                        return
                    else
                        % Correct type, so syntax must be bad
                        throwAsCaller(e);
                    end
                end
            else
                validateattributes(value, {mediaType}, {'scalar'}, mfilename, 'MediaType');
            end
            options.MediaType = char(value.Type + '/' + value.Subtype);
        end
        
        %------------------------------------------------------------------
        
        function options = set.ArrayFormat(options, value)
        % Validate and set ArrayFormat
            afType = 'matlab.net.ArrayFormat';
            if isa(value, afType)
                validateattributes(value, {afType}, {'scalar'}, mfilename, 'ArrayFormat');
                value = char(value);
            else
                % This test is redundant because validatestring checks this, but if the type is
                % wrong we want afType to be listed as a choice, which validatestring won't
                % do, so we need to do this first.
                validateattributes(value, {'string' 'char' afType}, ...
                                          {'scalartext'}, mfilename, 'ArrayFormat');
                % validate that the string is equal to one of the enumeration values
                [~, strs] = enumeration(afType);
                value = validatestring(value, strs, mfilename, 'ArrayFormat');
            end
            options.ArrayFormat = value;
        end
        
        %------------------------------------------------------------------
        
        function options = set.CertificateFilename(options, value)
            value = validateStringValue(value, 'CertificateFilename');
            if strcmpi(value, 'default')
                value = options.DefaultCertificateFilename;
            end
            options.CertificateFilename = value;
        end
        
        %------------------------------------------------------------------
        
        function options = set.Debug(options, value)
            validateattributes(value, {'logical'}, {'scalar'}, mfilename, 'Debug');
            options.Debug = value;
        end
    end
    
    %-------------------------- Custom display ----------------------------
       
    methods (Access = protected)
                
        function group = getPropertyGroups(options)
        % Provide a custom display for the case in which options is scalar
        % and Password is non-empty. Override the default display of
        % Password to replace each character with '*'.
            
            group = getPropertyGroups@matlab.mixin.CustomDisplay(options);
            if isscalar(options)
                password = group.PropertyList.Password;
                if ~isempty(password)
                    group.PropertyList.Password = repmat('*', size(password));
                end
            end
        end
    end
    
end

%--------------------------------------------------------------------------

function inputs = parseInputs(options, args)
% Parse the inputs from the args cell array. Set the default values from
% the properties of options. Value validation is not performed by this
% function.

% Construct the inputParser object.
p = inputParser;

% Add parameter names and default values.
props = properties(options);
for k = 1:length(props)
    p.addParameter(props{k}, options.(props{k}));
end

p.addParameter('Debug',options.Debug);

% Set the FunctionName and parse the values.
p.FunctionName = mfilename;
p.parse(args{:});

% Return parsed results.
inputs = p.Results;
end

%--------------------------------------------------------------------------

function options = setInputs(options, inputs)
% Assign the input values to options if they differ (to avoid unnecessary
% set validation).

names = fieldnames(inputs);
for k = 1:length(names)
    name = names{k};
    value = inputs.(name);
    try
        options.(name) = value;
    catch e
        throwAsCaller(e);
    end
end
end

%--------------------------------------------------------------------------

function value = validateCharacterEncoding(value)
% Validate CharacterEncoding value. Return a string.

if isstring(value)
    value = char(value);
end
validateattributes(value, {'char' 'string'}, {'scalartext'}, ...
    mfilename, 'CharacterEncoding');

% Validate value using native2unicode.
try
    native2unicode('a', value);
catch e
    if strcmp(e.identifier, 'MATLAB:unicodeconversion:InvalidCharset')
        % Create new message to indicate CharacterEncoding and provide
        % additional examples.
        id = 'MATLAB:webservices:InvalidCharacterEncodingSpecified';
        examples = '''US-ASCII'', ''UTF-8'', ''latin1'', ''Shift_JIS'', ''ISO-8859-1''';
        msg = message(id, 'CharacterEncoding', value, examples);
        e = MException(id, msg.getString());
    end
    throwAsCaller(e);
end
value =  value(:)';
end

%--------------------------------------------------------------------------

function value = validateStringValue(value, name)
% Validate value as a char vector or string. Return a char row vector or return the
% empty string, if value is empty.

if ~isempty(value)
    try
        validateattributes(value, {'char' 'string'}, {'scalartext'}, mfilename, name);
    catch e
        throwAsCaller(e);
    end
    value = char(value(:)');
else
    value = '';
end
end

%--------------------------------------------------------------------------

function validateStringMatrix(value)
% Validate value as an m-by-2 string matrix or cellstr. Allow empty values but not
% empty names
    if ~isempty(value) || ischar(value) % empty char errors out below
        if isstring(value) || iscellstr(value)
            % validate string or cell array is m-by-2
            validateattributes(value, {'string' 'cell'}, {'size', [NaN,2]}, ...
                               mfilename, 'HeaderFields')
            if iscell(value)
                % check for empty names in 1st column
                tf = any(cellfun(@isempty, value(:,1)));
                if ~tf
                    % check for any cells that aren't row vectors or empty
                    tf = any(cellfun(@(z)~isrow(z) && ~isempty(z), value(:)));
                end
            else
                % check for empty strings in 1st column
                tf = any(value(:,1)=='');
            end
            if tf
                error(message('MATLAB:webservices:ExpectedNonemptyHeader'));
            end
        else
            % not string array or cellstr; always error on type
            validateattributes(value, {'cell array of character vectors', 'string'}, ...
                              {}, mfilename, 'HeaderFields');
        end
    end
end
