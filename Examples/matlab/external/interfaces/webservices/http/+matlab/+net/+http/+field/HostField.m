classdef (Sealed) HostField < matlab.net.http.field.URIReferenceField
% HostField an HTTP Host header field whose value is a host and port
%   This header field is normally created automatically in a request message
%   from the URI you provide to RequestMessage.send, but you may want to
%   explicity create your own.
%
%   HostField methods:
%     HostField     - constructor
%     convert       - return URI
%
% See also matlab.net.URI, URIReferenceField

% Copyright 2016 The MathWorks, Inc.
    
    methods (Static, Hidden)
        function names = getSupportedNames()
            names = 'Host';
        end
    end
    
    methods
        function obj = HostField(varargin)
        % HostField creates an HTTP Host header field
        %   FIELD = HostField(URI) creates a field whose contents is the Host and Port
        %   from the specified URI. Other properties in the URI are ignored. URI may
        %   also be a string of the form host:port.
        %
        % See also matlab.net.URI
            obj = obj@matlab.net.http.field.URIReferenceField('Host', varargin{:});
        end
        
        function value = convert(obj)
        % convert returns the value of this field as a URI
        %   Only the Host and Port properties are filled in.
            if isscalar(obj)
                % Since the syntax of the field is host:port, it should be sufficient for us
                % to just add '//' to the front and have URI parse it
                value = matlab.net.URI('//' + obj.Value);
            elseif isempty(obj)
                value = matlab.net.URI.empty;
            else
                value = arrayfun(@convert, obj, 'UniformOutput', false);
                value = [value{:}];
            end
        end
    end
    
    methods (Access=protected, Hidden)
        function exc = getStringException(obj,value)
        % Determine if the string is a valid field value. We'll come here to validate
        % a string that the user specifies in the constructor. It must be of the form
        % host:port.
            try
                uri = matlab.net.URI.assumeHost(value);
                ok = ~isempty(uri.Host);
            catch
                ok = false;
            end
            if ok
                % above verified that it's a valid URI with a host name; now make sure that it
                % contains nothing else but a Host and Port by checking for empty UserInfo and
                % comparing input string to EncodedAuthority. This will rule out cases where
                % the user typed, for example, '//host:port', which we don't want to allow
                % because that literal string wouldn't be valid in this field.
                ok = isempty(uri.UserInfo);
                if ok
                    ok = strcmp(uri.EncodedAuthority, value);
                end
            else 
                ok = false;
            end 
            % value must equal getContentsFromURI
            if ~ok
                exc = obj.getValueError('MATLAB:http:InputMustBeHostPort', value);
            else
                exc = [];
            end
        end
        
        function str = getContentsFromURI(~, uri)
        % Overridden to return a string containing only 'host:port' from the uri,
        % ignoring all other properties.
            if isempty(uri.Host)
                error(message('MATLAB:http:URIMustNameHost', char(uri)));
            end
            str = uri.EncodedHostPort;
        end
    end
end
                
        