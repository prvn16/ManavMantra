classdef (Sealed) ProtocolVersion %< matlab.mixin.CustomDisplay
% ProtocolVersion Information about the protocol version in an HTTP message
%   This information may appear in the RequestLine of a RequestMessage, or the
%   StatusLine of a ReponseMessage. 
%   
%   ProtocolVersion methods:
%     ProtocolVersion   - constructor
%     string            - convert to string
%     char              - convert to character vector
%     isequal           - compare with another
%     eq, ==            - compare with another
%     
%   ProtocolVersion properties:
%     Name   - protocol name
%     Major  - Major version number
%     Minor  - Minor version number
%
% See also RequestLine, RequestMessage, ResponseMessage, StatusLine

% Copyright 2015-2015 The MathWorks, Inc.
    
    properties (Dependent)
        % Name - protocol name (string), e.g., 'HTTP'
        Name 
        % Major - major version number (integer 0-9)
        Major
        % Minor - minor version number (integer 0-9)
        Minor
    end
    
    properties (Access=private, Transient)
        String  % the version string
    end
        
    properties (Constant, Hidden)
        Default = matlab.net.http.ProtocolVersion('HTTP/1.1');
    end
    
    methods
        function obj = ProtocolVersion(name, major, minor)
        % ProtocolVersion constructor
        %   ProtocolVersion(string) - construct entire version string.  It should have
        %     the syntax such as HTTP/1.1, but no error occurs if it does not.
        %   ProtocolVersion(name, major, minor) - construct the version given the
        %     name (string), major and minor version numbers (integers).  This
        %     enforces proper syntax of the parameters.
            import matlab.net.internal.*;
            if nargin == 1
                if isempty(name)
                    obj = matlab.net.http.ProtocolVersion.empty;
                else
                    if isa(name,'matlab.net.http.ProtocolVersion')
                        obj = name;
                    else
                        obj.String = strtrim(getString(name,mfilename,'name')); 
                    end
                end
            else
                obj.Name = name;
                obj.Major = major;
                obj.Minor = minor;
            end
        end
        
        function name = get.Name(obj)
            name = obj.parse();
        end
        
        function major = get.Major(obj)
            [~, major] = obj.parse();
        end
        
        function minor = get.Minor(obj)
            [~, ~, minor] = obj.parse();
        end
        
        function obj = set.Name(obj, name)
            name = matlab.net.internal.getString(name, mfilename, 'Name');
            [~, major, minor] = obj.parse();
            obj.String = format(name, major, minor);
        end
        
        function obj = set.Major(obj, major)
            major = getInt(major,'Major');
            [name, ~, minor] = obj.parse();
            obj.String = format(name, major, minor);
        end
        
        function obj = set.Minor(obj, minor)
            minor = getInt(minor,'Minor');
            [name, major, ~] = obj.parse();
            obj.String = format(name, major, minor);
        end
        
        function str = char(obj)
        % char returns ProtocolVersion as a character vector
        %
        % See also string
            str = char(obj.String);
        end
        
        function str = string(obj)
        % string returns ProtocolVersion as a string
        %   STR = string(PV) returns the ProtocolVersion PV as a string in the format
        %   Name/Major.Minor, e.g. "HTTP/1.1"
        %
        % See also char
            str = obj.String;
        end
        
        function tf = isequal(obj, other)
        % isequal compares two ProtocolVersions
        %   tf = isequal(PV1, PV2) returns true if ProtocolVersion PV1 is functionally
        %   equal to PV2.  Comparison ignores case of the Name and uses numeric
        %   comparisons for Major and Minor.
        %
        % See also Name, Major, Minor
            tf = isa(other,'matlab.net.http.ProtocolVersion') && ...
                strcmpi(obj.Name,other.Name) && isequal(obj.Major,other.Major) && ...
                isequal(obj.Minor,other.Minor);
        end
        
        function tf = eq(obj, other)
        % eq, == compares two ProtocolVersions
        %   Same as isequal.
        %
        % See also isequal
            tf = isequal(obj, other);
        end
    end
    
    methods (Access=private)
        function [name, major, minor] = parse(obj)
        % parse the String and return the pieces as string, uint8 or [], uint8 or []
        % if syntax invalid, entire String returned in name and others are []
            if isempty(obj.String)
                name = [];
                major = [];
                minor = [];
            else
                fields = regexp(obj.String, '^([^ /]+)(/\d(\.\d)?)?$', 'tokens');
                if isempty(fields)
                    name = obj.String;
                    major = [];
                    minor = [];
                else
                    fields = fields{1};
                    name = fields(1); 
                    if length(fields) > 1 && ~isempty(fields{2})
                        % got the version as '/n.n' where the last .n is optional
                        version = regexp(extractAfter(fields(2),1), '(\d)(\.\d)?$', 'tokens');
                        version = version{1};
                        major = str2double(version{1});
                        if length(version{2}) > 1
                            minor = str2double(version{2}(2:end));
                        else
                            minor = [];
                        end
                    else
                        major = [];
                        minor = [];
                    end
                end
            end
        end
    end
end

function int = getInt(value, field)
    % get value (char or string) as uint8, verifying that it's a digit 0-9
    if ischar(value) || isstring(value)
        value = str2double(value);
    end
    validateattributes(value, {'numeric'}, {'scalar','nonnegative','<',10}, ...
                       mfilename, field);
    int = uint8(value);
end

function str = format(name, major, minor)
    if isempty(major)
        major = '';
    else
        major = ['/' num2str(major)];
    end
    if isempty(minor)
        minor = '';
    else
        minor = ['.' num2str(minor)];
    end
    str = name + major + minor;
end
