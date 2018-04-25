classdef (Sealed) RequestLine < matlab.net.http.StartLine & matlab.mixin.CustomDisplay
% RequestLine The first line of an HTTP request
%   In most cases this line is automatically created when you send or complete
%   a RequestMessage, based on the URI and parameters and options you specify,
%   but you can also create it explicitly and insert it into the
%   RequestMessage.RequestLine.
%
%   RequestLine methods:
%      RequestLine    - constructor
% 
%   RequestLine properties:
%      Method          - the request method
%      RequestTarget   - URI of the request target
%      Protocolversion - protocol version
%
% See also RequestMessage, matlab.net.URI

% Copyright 2015-2017 The MathWorks, Inc.
    properties (Dependent)
        % Method - a matlab.net.http.RequestMethod
        %   If you set this property to a string, it will be converted to a
        %   RequestMethod.
        %
        % See also RequestMethod
        Method % matlab.net.http.RequestMethod
        % RequestTarget - a matlab.net.URI object
        %   If you set this property to a string, it will be converted to a URI.  If
        %   you set this property explicitly its value must be consistent with the URI
        %   you specify when you send or complete a RequestMessage, and whether you
        %   have specified a proxy in HTTPOptions: If no proxy is being used, this URI
        %   must contain only an absolute path with optional query.  If a proxy is
        %   being used, this must be a full URI with a Scheme and Authority.  
        %
        %   The URI that is set in this property will be adjusted so that it always
        %   shows at least a leading '/' for the Path, even if the Path is relative or
        %   empty.
        %
        % See also matlab.net.URI, RequestMessage, HTTPOptions
        RequestTarget matlab.net.URI
        % ProtocolVersion - a matlab.net.http.ProtocolVersion object
        %   If you set this property to a string, it will be converted to a
        %   ProtocolVersion.
        %
        % ProtocolVersion
        ProtocolVersion matlab.net.http.ProtocolVersion
    end
    
    methods
        function obj = RequestLine(varargin)
        % RequestLine The first line of an HTTP RequestMessage
        %   RequestLine(STRING) - create a request line with the specified STRING.
        %     The STRING must consist of 1-3 parts separated by white space naming
        %     the Method, RequestTarget and ProtocolVersion.
        %
        %   RequestLine(METHOD,TARGET,VERSION) - create request line with components
        %     METHOD  - a string naming the method or a RequestMethod
        %     TARGET  - a URI or string acceptable to the URI constructor 
        %     VERSION - a ProtocolVersion or string acceptable to its constructor
        %     
        %     Trailing arguments may be omitted and [] can be specified as  
        %     placeholders.
        %
        %   See also Method, RequestTarget, ProtocolVersion, RequestMessage,
        %   RequestMethod, matlab.net.URI
            obj@matlab.net.http.StartLine(varargin{:});
            parts = obj.Parts;
            % Don't set [] parts so they stay [] instead of getting converted to whatever.empty
            if ~isempty(parts)
                if ~isempty(parts{1})
                    obj.Method = parts{1};
                end
                if length(parts) > 1 
                    if ~isempty(parts{2})
                        obj.RequestTarget = parts{2};
                    end
                    if length(parts) > 2 && ~isempty(parts{3})
                        obj.ProtocolVersion = parts{3};
                    end
                end
            end
        end
        
        function obj = set.Method(obj, value)
            if isempty(value)
                obj.Parts{1} = [];
            elseif isa(value, 'matlab.net.http.RequestMethod')
                obj.Parts{1} = value;
            else
                str = matlab.net.internal.getString(value, mfilename, 'Method');
                obj.Parts{1} = matlab.net.http.RequestMethod.(upper(char(str.replace('-','')))); 
            end
        end
        
        function obj = set.RequestTarget(obj, value)
            if ~isempty(value) || ischar(value)
                if isa(value, 'matlab.net.URI')
                    validateattributes(value, {'matlab.net.URI'}, {'scalar'}, ...
                                       mfilename, 'Target');
                else
                    value = matlab.net.URI(value);
                end
                % The target's EncodedPath must begin with a '/', so force this 
                % See help to URI.Path for why this works
                if ~value.EncodedPath.startsWith('/') 
                    if strlength(value.EncodedPath) == 0
                        value.Path = string.empty; 
                    else
                        value.Path = ['' value.Path];
                    end
                end
            end
            if isempty(value)
                value = [];
            end
            obj.Parts{2} = value;
        end
        
        function obj = set.ProtocolVersion(obj, value)
            if isempty(value)
                obj.Parts{3} = value;
            else
                obj.Parts{3} = matlab.net.http.ProtocolVersion(value);
            end
        end
        
        function value = get.Method(obj)
            if isempty(obj.Parts)
                value = [];
            else
                value = obj.Parts{1};
            end
        end
        
        function value = get.RequestTarget(obj)
            if length(obj.Parts) < 2
                value = [];
            else
                value = obj.Parts{2};
            end
        end
        
        function value = get.ProtocolVersion(obj)
            if length(obj.Parts) < 3
                value = [];
            else
                value = obj.Parts{3};
            end
        end
        
    end
    
    methods (Access=?matlab.net.http.RequestMessage)
        function obj = finish(obj, uri, useProxy, method)
        % Fill the unset properties of this object with default values, based on the
        % method and the uri to which the message will be sent and whether or not it
        % will be sent to a proxy.  Throw an error if a property has a value
        % inconsistent with the uri or useProxy.
            import matlab.net.http.*;
            import matlab.net.URI;
            % Complete the RequestTarget property based on the method and whether message
            % is to a proxy
            uri.Fragment = [];
            switch (char(method))
                case RequestMethod.CONNECT
                    % authority-form has only host and port
                    target = URI;
                    target.Host = uri.Host;
                    target.Port = uri.Port;
                case RequestMethod.OPTIONS
                    % asterisk-form
                    target = URI;
                    target.Host = '*';
                otherwise
                    if useProxy && uri.Scheme ~= 'https'
                        % if using proxy and not SSL, use full URI ("absolute-form") minus UserInfo
                        target = uri;
                        target.UserInfo = [];
                        if isempty(target.Port)
                            % default port is always 80
                            target.Port = 80;
                        end
                    else
                        % If not using proxy or SSL, use origin-form containing just the
                        % Path and Query by wiping out the previous properties
                        uri.Scheme = [];
                        uri.UserInfo = [];
                        uri.Host = [];
                        uri.Port = [];
                        target = uri;
                    end
                    if isempty(target.Path)
                        % force empty path to convert to '/'
                        target.Path = {};
                    end
            end
            if isempty(obj.RequestTarget) 
                obj.RequestTarget = target;
            else
                if ~isequal(obj.RequestTarget, target)
                    error(message('MATLAB:http:BadTarget', char(obj), char(obj.RequestTarget), char(target)));
                end
            end
            if isempty(obj.RequestTarget)
                % If Target not set, do it from the Path of the URI.  This assumes
                % target is not a proxy.  If it's a proxy, caller is expected to have
                % set the Target
                uri = URI;
                uri.Path = uri.Path;
                obj.RequestTarget = uri;
            end
            if isempty(obj.Method)
                obj.Method = matlab.net.http.RequestMethod.GET;
            end
            if isempty(obj.ProtocolVersion)
                obj.ProtocolVersion = matlab.net.http.ProtocolVersion.Default;
            end
        end
    end

    methods (Access=protected)
        function group = getPropertyGroups(obj)
        % Provide a custom display that displays the target and protocol stringified
            if isscalar(obj)
                group = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
                group.PropertyList.RequestTarget = string(group.PropertyList.RequestTarget);
                if isempty(group.PropertyList.RequestTarget)
                    % so it doesn't display as "0x0 string"
                    group.PropertyList.RequestTarget = [];
                end
                if ~isempty(group.PropertyList.ProtocolVersion)
                    group.PropertyList.ProtocolVersion = string(group.PropertyList.ProtocolVersion);
                end
            end
        end
    end
    
end

