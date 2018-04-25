classdef  (Sealed) StatusLine < matlab.net.http.StartLine
%StatusLine  The status line in an HTTP response message
%   The server inserts this information into every HTTP ResponseMessage. You
%   can obtain this information as a raw string using char or string, or examine its
%   individual fields. For more information on the meaning of this line, see 
%   RFC 7230, <a href="http://tools.ietf.org/html/rfc7230#section-3.1.2">section 3.1.1</a>.
%
%   StatusLine properties:
%     ProtocolVersion    - protocol version
%     StatusCode         - status code
%     ReasonPhrase       - reason phrase

% Copyrigth 2015-2017 The MathWorks, Inc.
    
    properties (Dependent)
        % ProtocolVersion - protocol version, a ProtocolVersion object
        %
        % See also matlab.net.http.ProtocolVersion
        ProtocolVersion matlab.net.http.ProtocolVersion
        
        % StatusCode - status code: a StatusCode enumeration, a string, or an int
        %   The value is a StatusCode object if the server returns one of its
        %   enumeration values. Otherwise the value is either a number (if the
        %   server returns a number) or a string.
        %
        % See also matlab.net.http.StatusCode
        StatusCode
        
        % ReasonPhrase - text describing the status reason (string)
        %   This value may be empty if the server did not provide a reason. This
        %   value is not necessarily the same as StatusCode.getReasonPhrase.
        %
        % See also StatusCode
        ReasonPhrase string
    end
    
    methods
        function obj = set.ProtocolVersion(obj, value)
            if isempty(value)
                obj.Parts{1} = [];
            else
                obj.Parts{1} = matlab.net.http.ProtocolVersion(value);
            end
        end
        
        function obj = set.StatusCode(obj, value)
        % This function attempts to convert the value to a StatusCode enumeration, 
        % but if that fails, store it as either a number or (if that fails) a string.
        % The idea is that no input is invalid, because this field is set from data
        % provided by the server, and we don't want to error out on malformed inputs.
            if isempty(value)
                obj.Parts{2} = [];
            else
                try
                    % First try to convert to a known StatusCode value. This works
                    % if value is a number or string.
                    obj.Parts{2} = matlab.net.http.StatusCode.fromValue(value); 
                catch 
                    % not known or not number or string; just store the number if
                    % it's a number
                    if isnumeric(value) && isscalar(value) && isreal(value)
                        obj.Parts{2} = value;
                    else
                        % otherwise it must be a string; this errors if anything else
                        value = matlab.net.internal.getString(value,mfilename,'StatusCode');
                        % try to convert string to number
                        obj.Parts{2} = str2double(value);
                        if isnan(obj.Parts{2})
                            % still fails; just store the string
                            obj.Parts{2} = value;
                        end
                    end
                end
            end
        end
        
        function obj = set.ReasonPhrase(obj, value)
            obj.Parts{3} = string(value);
        end
        
        function value = get.ProtocolVersion(obj)
            if isempty(obj.Parts)
                value = [];
            else
                value = obj.Parts{1};
            end
        end
        
        function value = get.StatusCode(obj)
            if length(obj.Parts) >= 2
                value = obj.Parts{2};
            else
                value = [];
            end
        end
        
        function value = get.ReasonPhrase(obj)
            if length(obj.Parts) >= 3
                value = obj.Parts{3};
            else
                value = [];
            end
        end
        
        function str = char(obj)
            if isnumeric(obj.StatusCode)
                str = [char(obj.ProtocolVersion) ' ' num2str(obj.StatusCode) ...
                       ' ' char(obj.ReasonPhrase)];
            else
                str = char@matlab.net.http.StartLine(obj);
            end
        end
    end
        
    methods 
        function obj = StatusLine(varargin)
        % StatusLine constructor
        %   LINE = StatusLine(STRING)
        %   LINE = StatusLine(ProtocolVersion,StatusCode,ReasonPhrase)
        %     Create a status line with the specified STRING or with a
        %     matlab.http.net.ProtocolVersion, matlab.http.net.StatusCode, and
        %     ReasonPhrase (string). This line normally appears in a ResponseMessage
        %     and is created automatically from a server's response by
        %     RequestMessage.send. This constructor is provided for testing
        %     purposes.
        %
        % See also ProtocolVersion, StatusCode, ResponseMessage, RequestMessage.send
            obj@matlab.net.http.StartLine(varargin{:});
            for i = 1 : length(obj.Parts)
                arg = obj.Parts{i};
                switch i
                    case 1, obj.ProtocolVersion = arg;
                    case 2, obj.StatusCode = arg;
                    case 3, obj.ReasonPhrase = arg;
                end
            end
        end
    end
    
    methods (Access=protected, Hidden)
        function obj = setFields(obj, fields)
            lf = length(fields);
            if lf >= 1
                obj.ProtocolVersion = fields{1};
                if lf >= 2
                    obj.StatusCode = fields{2};
                    if lf >= 3
                        obj.ReasonPhrase = fields{3};
                    end
                end
            end
        end
    end
end

