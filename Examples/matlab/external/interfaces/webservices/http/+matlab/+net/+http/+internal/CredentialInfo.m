classdef (Sealed) CredentialInfo < handle & matlab.mixin.CustomDisplay
    % CredentialInfo Information about a successful or attempted authentication using
    %   native credentials. A vector of successful CredentialInfos is stored in each
    %   Credentials object that has been used to used to authenticate a request. It
    %   is a handle because it may be updated implicitly each time it is used for
    %   authentication.
    %
    % This class is for internal use only. It may change in a future release.
    
    % Copywrite 2015-2016 The MathWorks, Inc.
    
    properties (Access={?matlab.net.http.Credentials,...
                        ?matlab.net.http.RequestMessage,...
                        ?tHTTPCredentialsUnit})
        % A vector of absolute URIs suitable for authentication using this object.
        % For Basic, it contains just one URI that has everything up to and including
        % the Path of the requestURI specified to the constructor (possibly trimmed
        % to a "common prefix" by future requests). For Digest, if AuthInfo.domain
        % is missing, it is everything in the requestURI up to and including the Port
        % (no Path). If AuthInfo.domain is set, it is a vector of the URIs in that
        % domain, made absolute relative to the requestURI.
        %
        % This vector is never empty.
        URIs     
        
        % AuthInfo specified in constructor. AuthInfo.Scheme specifies the
        % AuthenticationScheme to which this CredentialInfo applies. This information
        % came from the challenge in an AuthenticateField.
        AuthInfo
        
        % The datetime when this object was last successfully used
        LastUsed
        
        % True if this is for a proxy. In this case URIs contains only the single
        % URI of the proxy, with Host and Port only.
        ForProxy = false
    end
    
    properties (Access=?matlab.net.http.internal.HTTPConnector)
        % Native HTTPCredentials, updated on each authentication. It is basically a
        % reference to a native object that maintains authentication state that is
        % needed for Digest authentication of multiple requests to the same server. A
        % given HTTPCredentials object is referenced by exactly one CredentialInfo,
        % and CredentialInfo is not copyable. Hence, the HTTPCredentials object is
        % destroyed when this CredentialInfo is destroyed.
        HTTPCredentials  
    end
    
    properties (Access={?matlab.net.http.Credentials,?matlab.net.http.internal.HTTPConnector})
        % The username and password provided to the constructor. This is the one we
        % actually used to authenticate (or tried to), which may have come from the
        % GetCredentialsFcn or Username property of the Credentials object containing
        % this CredentialInfo.
        Username
        
        % The password provided to the constructor, that we actually used to
        % authenticate (or tried to)
        Password
    end        
    
    methods
       function set.Password(obj, str)
            obj.Password = string(str);
        end
        
        function set.Username(obj, str)
            obj.Username = string(str);
        end
        
        function tf = eq(obj, other)
            equals = @(a,b) a.URIs == b.URIs && ...
                ((isempty(a.AuthInfo) && isempty(b.AuthInfo)) || ...
                 (~isempty(a.AuthInfo) && a.AuthInfo == b.AuthInfo)) && ...
                a.ForProxy == b.ForProxy;
            if size(obj) == size(other)
                if ~strcmp(class(obj),class(other))
                    error(message('MATLAB:http:MustBeSameClass'));
                else
                end
                if isscalar(obj)
                    % vanilla scalar compare
                    tf = equals(obj,other);
                else
                    % Both args not scalars but sizes same, return array
                    tf = arrayfun(@(a,b) equals(a,b), obj, other);
                end
            elseif isscalar(other)
                % obj is array or []; scalar expansion of other
                % returns [] if obj is []
                tf = arrayfun(@(a) equals(a, other), obj);
            elseif isscalar(obj)
                % other is array or []; scalar expansion of obj
                % returns [] if other is []
                tf = arrayfun(@(b) equals(obj, b), other);
            else
                % neither is scalar or [] and dimension sizes differ
                error(message('MATLAB:dimagree'));
            end
        end
    end
    
    methods (Access={?matlab.net.http.Credentials,?matlab.net.http.RequestMessage})
        function obj = CredentialInfo(authInfo, requestURI, username, password, forProxy)
        % CredentialInfo construct a CredentialInfo 
        %
        %  This constructor is called by the infrastructure when it finds a matching
        %  Credentials object for a request that does not already contain a matching
        %  CredentialInfo, to create actual credentials that can be used to
        %  authenticate the next request. If authentication with this CredentialInfo
        %  is successful, the infrastructure adds this object to its vector of
        %  CredentialInfos in the appropriate Credentials object.
        %
        %  authInfo   The AuthInfo from the challenge to which we are attempting to
        %             respond with this CredentialInfo. However, in the case of
        %             Basic, where we are proactively sending credentials prior to
        %             getting a challenge, this contains a dummy AuthInfo containing
        %             only a Scheme property set to Basic. It may also be empty if
        %             this is a CredentialInfo constructed from proxy credentials
        %             obtained from preferences where we don't know (yet) whether
        %             the proxy requires Basic or Digest.
        %  requestURI The URI of the request. 
        %
        %  username   The username and password from the Credentials object or
        %  password   the ones returned by the GetCredentialsFcn. The username may
        %             be "" to indicate an empty username, but not [].

            import matlab.internal.webservices.HTTPCredentials % a native object
            import matlab.net.URI
            import matlab.net.http.AuthenticationScheme
            
            assert(~isempty(requestURI));
            
            % Construct the native credentials object
            if ~isempty(authInfo)
                scheme = authInfo.Scheme;
            else
                scheme = -1;
            end
            % These handle cases where username and/or password are string.empty or
            % []
            if isempty(username)
                username = '';
            end
            if isempty(password)
                password = '';
            end
            obj.HTTPCredentials = HTTPCredentials(char(username), char(password), ... 
                                              scheme == AuthenticationScheme.Basic);
            obj.Username = string(username);
            obj.Password = string(password);
            obj.AuthInfo = authInfo;
            if nargin > 4
                obj.ForProxy = forProxy;
            end
            
            % For Basic, or Digest with no domain, URIs same as requestURI minus
            % query and fragment
            isDigest = scheme == AuthenticationScheme.Digest;
            if ~isDigest || isempty(authInfo.getParameter('domain'))
                uri = requestURI;
                uri.Query = [];
                uri.Fragment = [];
                if isDigest
                    uri.Path = [];
                end
                obj.URIs = uri;
            else
                % This is Digest with domain. Copy URIs in domain to URIs, making
                % them absolute based on the requestURI
                uris = arrayfun(@requestURI.resolve, authInfo.getParameter('domain'), ...
                               'UniformOutput', false);
                obj.URIs = [uris{:}]; % Uncellify
            end           
        end
        
        %{ 
        TBD: Function subsumed by Credentials.getBestCredInfo and it's not easy to see how
        to break this out. Saving for now in case I figure it out.
        
        function res = matches(obj, uri)
        % Given a vector of CredentialInfo, return the most specific one that has a
        % URI in its URIs that fully matches a prefix of the specified uri. If more
        % than one equally specific, return all. "Most specific" means longest match
        % based on Path segments. Prefix match uses everything up to and including
        % the Path in the URIs. This is intended to implement the match specified for
        % the "domain" attribute for Digest authentcation in section 3.2.1 of RFC
        % 2617 as well as the Basic match in section 2 that refers to "all paths at
        % or deeper than".
        
            % find the longest match of URIs to the prefix of uri
            for i = length(obj) : -1 : 1
                % matchLengths(i) is maximum length of prefix match among obj(i).URIs
                matchLen = max(obj.URIs.matchLength(uri));
                matchLengths(i) = matchLen;
            end
            % return all the objs whose match equals the max
            res = obj(matchLengths == max(matchLengths));
        end   
        %}
        
        function res = commonPrefix(obj, uri)
        % Given a vector of CredentialInfo, return those having a URI in URIs that
        % matches uri for everything up to but not including the Path.
        % TBD: this should sort the results by the longest common prefix first.
            uriMatch = uri.trimAtPath();
            % prefixMatch returns true if any o.URIs(:) matches uriMatch
            prefixMatch = @(o) any(arrayfun(@(u) uriMatch == u.trimAtPath(), o.URIs));
            res = obj(arrayfun(@(o) prefixMatch(o), obj));
        end
        
        function obj = chopCommonPrefix(obj, uri)
        % Trim the URI in this CredentialInfo to the common prefix with uri. Should
        % only be applied to a Basic, used when a previous authentication was for
        % www.host.com/foo/bar and another was for www.host.com/foo/baz with the same
        % username and password. In this case we want to retain just a single
        % CredentialInfo with the common prefix www.host.com/foo, under the
        % assumption that all paths under www.host.com/foo use the same credentials.
        
            % While Basic only supports one URI per CredentialInfo, this code is
            % written to handle multiples in case we choose to save multiple URIs in
            % the same CredentialInfo.
            assert(isscalar(obj) && ...
                obj.AuthInfo.Scheme == matlab.net.http.AuthenticationScheme.Basic);
            
            % The <= test tells us one of the URIs fully matches the prefix of uri,
            % in which case we need do nothing. For example the uri is
            % www.host.com/foo/bar but we already have a URI for www.host.com/foo
            if ~(any(obj.URIs <= uri))
                % No full prefix match, so trim every URI that matches up to but not
                % necessarily including Path to common Path prefix.
                uriMatch = uri.trimAtPath();
                for i = 1 : length(obj.URIs)
                    testURI = obj.URIs(i);
                    % Caller should not have told us to trim a path in a
                    % CredentialInfo that doesn't apply to the same host.
                    assert(uriMatch == testURI.trimAtPath());
                    % Everything up to path matches, so trim at first nonmatching
                    % path segement. This may trim off the entire Path if nothing
                    % after the host matches.
                    len = testURI.matchPath(uri);
                    obj.URIs(i).Path(len+1:end) = [];
                end
            end
        end
        
        function tf = appliesTo(obj, another)
        % return true if username and password in another CredentialInfo are the
        % same as in this object. This function is provided to keep these properties
        % private.
            % use isequal instead of == because one or the other may be []
            tf = isequal(obj.Username,another.Username) && ...
                 isequal(obj.Password, another.Password);
        end
        
        function obj = updateCreds(obj, username, password)
            obj.Username = username;
            obj.Password = password;
        end
        
    end
    
    methods (Access = protected, Hidden)
        % These methods are overridden for test purposes only. Since we never return
        % a CredentialInfo to the user, only code or debuggers with access to this
        % object will use these functions. No need for automated tests on this code.
        
        function group = getPropertyGroups(obj)
        % Override to display normally hidden and private properties, replacing
        % characters of Password with '*' and displaying strings for the URIs
            if isscalar(obj)
                password = obj.Password;
                if ~isempty(password)
                    pw(1:strlength(password)) = '*';
                    password = string(pw);
                end
                group = matlab.mixin.util.PropertyGroup(struct(...
                    'URIs',     strjoin(arrayfun(@char, obj.URIs, ...
                                                 'UniformOutput',false),...
                                        ', '), ...
                    'AuthInfo', string(obj.AuthInfo), ...
                    'LastUsed', obj.LastUsed, ...
                    'ForProxy', obj.ForProxy, ...
                    'Username', obj.Username, ...
                    'Password', password));
            else
                group = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            end
        end
        
        function displayNonScalarObject(obj)
        % Overridden to display properties of all elements of an array
            arrayfun(@displayScalarObject, obj);
        end
    end
end

