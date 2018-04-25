classdef (Sealed) Credentials < handle & matlab.mixin.Copyable & matlab.mixin.CustomDisplay
    % Credentials Credentials for authenticating HTTP requests
    %   You may include a vector of these Credentials in the HTTPOptions.Credentials
    %   property to specify authentication credentials when sending a RequestMessage
    %   to servers that may require authenticaiton. The RequestMessage.send method
    %   uses these credentials to respond to authentication challenges from servers
    %   or proxies. The authentication challenge from the server or proxy is
    %   contained in an AuthenticateField (with the name 'WWW-Authanticate' or
    %   'Proxy-Authenticate') and specifies one or more AuthenticationSchemes that
    %   the server or proxy is willing to accept to satisfy the request.
    %
    %   Exact behavior depends on the AuthenticationScheme, but in general MATLAB
    %   searches the vector of Credentials for one that applies to the request URI
    %   and which supports the specified AuthenticationScheme, and resends the
    %   original request with appropriate credentials in an AuthorizationField
    %   header. If multiple Credentials apply, the "most specific" one for the
    %   strongest scheme is used. If there are duplicates, the first one is used.
    %
    %   Currently MATLAB implements only the Basic and Digest schemes. If the server
    %   requires other schemes, or you don't supply Credentials for the required
    %   scheme, you will receive the authentication response message (which will have
    %   a StatusCode of 401 or 407) and must implement the appropriate response
    %   yourself.
    %
    %   Once MATLAB carries out a successful authentication using a Credentials
    %   object, MATLAB saves the results in this Credentials object so that it will
    %   proactively apply these credentials on subsequent requests without waiting
    %   for an authentication challenge from the server. To take advantage of this,
    %   provide the same Credentials instance on subsequent requests, in the same
    %   or other HTTPOptions objects.
    %
    %   This object is a handle, as it internally accumulates information about prior
    %   (successful) authentications, so that the information can be reused for
    %   subsequent messages. If you insert this object into multiple HTTPOptions, it
    %   may be updated on each use. You may copy the object using the copy method,
    %   but that only copies the visible properties that you have set, not the
    %   internal state.
    %
    %   Credentials properties:
    %      Scheme            - vector of AuthenticationScheme to which Credentials applies
    %      Scope             - vector of URI to which Credentials applies
    %      Realm             - vector of string, the realm(s) to which this Credentials applies
    %      Username          - string, the username to use for authentication
    %      Password          - string, the password to use for authentication
    %      GetCredentialsFcn - function handle, to obtain username and password
    %                          without embedding them in this object
    %
    %   Credentials methods:
    %      Credentials       - constructor
    %
    %   Example:
    %
    %      % insure these credentials sent only to appropriate server
    %      scope = URI('http://my.server.com');
    %      creds = Credentials('Username','John','Password','secret','Scope',scope);
    %      options = HTTPOptions('Credentials',creds);
    %      % if the server requires authentication, the following transaction will 
    %      % involve an exchange of several messages
    %      req = RequestMessage;
    %      resp = req.send(scope, options);
    %      ...
    %      % later, reuse same options that contains same credentials
    %      % since credentials already used successfully, this transaction will only
    %      % require a single message
    %      resp = req.send(scope, options)
    %
    % See also HTTPOptions.Credentials, AuthenticationScheme, RequestMessage
    % StatusCode
    
    % Copyright 2015-2017 The MathWorks, Inc.
    properties
        % Scheme - vector of AuthenticationScheme to which the credentials apply
        %   Default is [AuthenticationScheme.Basic, AuthenticationScheme.Digest]. If
        %   empty, it applies to all AuthenticationSchemes. 
        %
        %   If you set this to Basic only, these credentials may be automatically
        %   applied to a request (in an AuthorizationField) whether or not the server
        %   requests authentication. This avoids an extra round trip responding to
        %   an authentication challenge (since Basic does not require a challenge),
        %   but could be undesirable if you are not sure whether the server requires
        %   Basic authentication, as it exposes the Username and Password to the
        %   server in all cases.
        %
        %   If Digest one of the listed options (or if this property is empty), the
        %   first message to which these Credentials potentially apply (based on
        %   Scope and the request URI) will be sent without an Authorization header
        %   field: these Credentials will be used only if the server responds with a
        %   challenge (providing, of course, that the Scope and Realm match the URI
        %   and the server's challenge).
        %
        %   See also AuthenticationScheme, Scope, Realm, matlab.net.URI
        Scheme matlab.net.http.AuthenticationScheme = ...
                 [matlab.net.http.AuthenticationScheme.Basic, ...
                  matlab.net.http.AuthenticationScheme.Digest]
        
        % Scope - vector of URI or strings to which the credentials apply
        %   The strings must be acceptable to the URI constructor, or of the form
        %   "host/path/..."  Values in this vector are compared against the URI in the
        %   request to determine whether this Credentials object applies. Normally
        %   this Credentials applies if the request URI refers to the same host at a
        %   path at or deeper than one of the URIs in this Scope. For example a Scope
        %   containing URI naming a host, with no path, applies to request URIs for
        %   all paths on that host.
        %
        %   Only the Host, Port and Path portions of the Scope URIs are used.
        %   Typically you would just specify a Host name, such as
        %   'www.mathworks.com', but you can include a Path, or portion of one, if
        %   you know that the credentials are needed only for some paths within that
        %   Host. A Host of 'mathworks.com' would match a request to
        %   'www.mathworks.com' as well as 'anything.mathworks.com'. A URI of
        %   'mathworks.com/foo/bar' would match a request to
        %   'www.mathworks.com/foo/bar/baz' but not to 'www.mathworks.com/foo'
        %   because the latter has a path '/foo' that is not at or deeper than
        %   '/foo/bar'.
        %
        %   An empty Scope (default), or an empty Host or Path in this vector matches
        %   all Hosts or Paths. You should not leave this property empty if Scheme
        %   is set to Basic only, unless you are careful to send your requests only
        %   to trusted servers, as this would send your Username and Password to any
        %   servers you access using the HTTPOptions containing this Credentials
        %   object.
        %
        %   See also matlab.net.URI, AuthenticationScheme
        Scope
        
        % Realm - vector of regular expressions describing realms for credentials
        %   This may be a string array, character vector, or cell array of character
        %   vectors. A realm is a string specified by the server in an
        %   AuthenticateField that is intended to be displayed to the user, so the
        %   user knows what name and password to use. It is useful when a given
        %   server requires different logins for different URIs.
        %
        %   The realm expressions in this list are compared against the
        %   authentication realm in the server's authentication challenge, to
        %   determine whether this Credentials object applies. Once MATLAB carries
        %   out a successful authentication using one of these realms, MATLAB will
        %   proactively apply this Credentials object to subsequent requests (using
        %   this same Credentials object) to the same Host and Path in the request
        %   URI without requiring another authentication challenge from the server,
        %   or a call to GetCredentialsFcn, on every request.
        %
        %   If you want to anchor the regular expression the start or end of the
        %   authentication realm string, include the '^' or '$' as appropriate.
        %
        %   If this property is [] it is considered to match all realms. If any
        %   value is an empty string, it only matches an empty or unspecified realm.
        %
        %   In general you would leave this property empty. Use it only if you want
        %   to specify different Credentials for different realms on the same server
        %   and are not prompting the user for a name and password.
        %
        %   See also regexp, AuthenticationScheme, GetCredentialsFcn
        Realm string
        
        % Username - user name for Basic or Digest authentication schemes
        %   If you set this and the Password property to any string (including an
        %   empty one) this user name will be used for authentication of any request
        %   for which this Credentials object applies, unless GetCredentialsFcn is
        %   specified. If you set this to [] then you must specify a
        %   GetCredentialsFcn or authentication will not be attempted. 
        %
        %   See also GetCredentialsFcn, AuthenticationScheme
        Username string
        
        % Password - password for Basic or Digest authentication schemes
        %   If you set this and the Username properties are any string (including an
        %   empty one) this password will be used for authentication to any request
        %   for which this Credentials object applies, unless GetCredentialsFcn is
        %   specified. If you set this to [] then no password will be provided.
        %
        %   See also GetCredentialsFcn, AuthenticationScheme
        Password string
        
        % GetCredentialsFcn - handle to function providing username and password
        %  If you set this property, this function will be called to obtain the
        %  username and password to use for the authentication response, even if the
        %  Username or Password properties in this Credentials object are set. This
        %  function must take 4-6 input arguments and return at least 2 outputs, with
        %  the following signature:
        %
        %  [username,password] = GetCredentialsFcn(cred,request,response,authInfo,...
        %                                          previousUsername,previousPassword)
        %
        %     cred      handle to this Credentials object
        %     request   the last sent RequestMessage that provoked this
        %               authentication request. 
        %     response  the ResponseMessage from the server containing an
        %               AuthenticateField. May be empty if this function is being
        %               called prior to getting a response (possible if this
        %               cred.Scheme specifies only Basic).
        %     authInfo  (optional) one element in the vector of AuthInfo returned by 
        %               AuthenticateField.convert() that MATLAB has selected to match
        %               with this Credentials object. Each object in this array will
        %               have at least Scheme and realm fields. If you have no use
        %               for this information you needn't specify this argument.
        %     previousUsername, previousPassword (optional)
        %               Initially empty. If set, these are the values the
        %               GetCredentialsFcn returned in a previous invocation, which
        %               were not accepted by the server. If you are not prompting
        %               the user for credentials, you should compare these values to
        %               the ones you plan to return. If they are the same, return []
        %               for the username to indicate that we should give up with an
        %               authentication failure. If you are prompting the user for
        %               credentials you needn't specify these arguments.
        %     username  the username to use. It may be '' or "", to indicate
        %               the username should be left empty (some servers may require
        %               only a password, not a username), but if [] this says we
        %               should give up and abort the authentication.
        %     password  the password to use.
        %
        %  By implementing this function and leaving the Username and/or Password in
        %  this Credentials empty, you can implement a prompt or other mechanism to
        %  obtain these values from the user without embedding them in your program.
        %  In your prompt, you may want to display the URI of the request and/or the
        %  realm from authInfo. A convenient pattern may be to set the Username in
        %  the Credentials object and prompt only for the password. Your prompt can
        %  display that existing Username (or the previousUsername, if set) and give
        %  the user the option to change it.
        %  
        %  The function can examine this Credentials object (the cred argument) as
        %  well as header fields in the request and response to determine which
        %  resource is being accessed, so it can prompt the user for the correct
        %  credentials. In general the prompt should display authInfo.realm to let
        %  the user know the context of the authentication.
        %
        %  Since the cred parameter is a handle, this function can store the desired
        %  username and password in this object, so that they will be reused for
        %  future requests without invoking the function again. Usually this is not
        %  necessary, as MATLAB already saves the username and password internally so
        %  it can apply them to future requests. But MATLAB may not always be able
        %  to determine whether the same username and password apply to different
        %  requests using this Credentials object.
        %
        %  If the function returns [] (as opposed to an empty string) for the
        %  username, this means that authentication is denied and MATLAB returns the
        %  server's authentication failure response message to the caller of send.
        %  This is appropriate behavior if you are implementing a user prompt and the
        %  user clicks cancel in the prompt. If you are supplying the username and
        %  password programmatically rather than propmting the user, you must return
        %  [] if the previousUsername and previousPassword arguments passed in are
        %  identical to the username and password that you would return (thus
        %  indicating that your credentials are not being accepted and you have no
        %  alternative choice). Otherwise, an infinte loop might occur calling your
        %  GetCredentaislFcn repeatedly.
        %
        %  This is an example of a simple GetCredentialsFcn that prompts the user,
        %  that fills in the Username from the Credentials object as a default:
        %
        %    function [u,p] = getMyCredentials(cred, req, resp, authInfo)
        %        u = cred.Username;
        %        prompt{1} = 'Username:';
        %        prompt{2} = 'Password:';
        %        defAns = {char(u), ''};
        %        title = ['Credentials needed for ' char(getParameter(authInfo,'realm'))];
        %        answer = inputdlg(prompt, title, [1, 60], defAns, 'on');
        %        if isempty(answer)
        %            u = [];
        %            p = [];
        %        else
        %            u = answer{1};
        %            p = answer{2};
        %        end
        %    end
        %
        %  The above function prevents the password from being stored in any 
        %  accessible property.
        %
        %  See also RequestMessage, matlab.net.http.field.AuthenticateField, AuthInfo
        GetCredentialsFcn 
    end
    
    properties (Access=private)
        % CredentialInfos - Vector of matlab.internal.webservices.CredentialInfo 
        %   created or updated by updateCredential() containing information needed to
        %   authenticate subsequent requests using this Credentials object without
        %   waiting for an authentication challenge from the server. On each new
        %   request we first search all CredentialInfos in all Credentials objects to
        %   see if any one applies to the request URI. If we find none, we search
        %   the Credentials objects to look for the most specific match. If we find
        %   no matching Credentials object we send the request without
        %   authentication. In this case a response containing an authentication
        %   challenge (401 or 407) can't be answered and we'll return the challenge
        %   to the user.
        %
        %   If we don't find a CredentialInfo (which means we never authenticated to
        %   this URI), and the most specific matching Credentials object specifies
        %   only AuthenticationScheme.Basic, we send those credentials with the
        %   request. If the most specific matching Credentials specifies a scheme
        %   other than Basic, or its Scheme is empty, we send the request without
        %   credentials. If the server comes back with an authentication challenge
        %   (saved as AuthInfo), we once again look for the most specific matching
        %   Credentials object (this time using information in the challenge such as
        %   Scheme and Realm, as well as the URI) and use its credentials to respond
        %   to the challenge.
        %   
        %   When an authentication is successful, we add a new CredentialInfo object
        %   to this array in Credentials object from which we obtained the
        %   credentials.
        %
        %   If we find a CredentialInfo object in that matches the request URI, which
        %   means we previously authenticated using that CredentialInfo, MATLAB will
        %   update the CredentialInfo and send its credentials with the request,
        %   without waiting for a challenge. If authentication fails (i.e., we get a
        %   challenge anyway), and the URI in the CredentialInfo is identical to that
        %   in the request, we delete the CredentialInfo and retry the request as if
        %   there had been no CredentialInfo. If the URI is not an exact match, or
        %   if we deleted the CredentialInfo, we go back to the paragraph above as if
        %   we never authenticated to this URI.
        %
        %   We never remove an entry from this list unless its URI exactly matches
        %   that of a request whose authentication has failed. For example, say we
        %   add an entry for www.mathworks.com/foo. If a subsequent request is for
        %   www.mathworks.com/foo/bar, we try to use the existing entry. If it
        %   succeeds, we just update the existing entry. If it fails, we
        %   authenticate from scratch and if that succeeds, we add a new entry for
        %   www.mathworks.com/foo/bar and keep both. If a subsequent request comes
        %   in for www.mathworks.com/foo/baz, we again try to use the first entry, as
        %   it's the only one that matches. If authentication with that entry fails,
        %   we again start from scratch and add a 3rd entry for
        %   www.mathworks.com/foo/baz. 
        %
        %   This property is not copied by the copy() method.
        %
        CredentialInfos = matlab.net.http.internal.CredentialInfo.empty
    end
    
    
    methods
        function obj = Credentials(varargin)
        %Credentials constructor
        %   CREDENTIALS = Credentials(Name,Value) returns a Credentials object
        %   with named properties initialized to the specified values. Unnamed
        %   properties get their default values, if any.
        
        % Undocumented behavior: allow a single argument that is a Credentials array
        % which returns handle to same array, or [] which returns empty array.
            if nargin ~= 0
                arg = varargin{1};
                if isempty(arg) && isnumeric(arg)
                    obj = matlab.net.http.Credentials.empty;
                else
                    if nargin == 1 && isa(arg,class(obj))
                        obj = arg;
                    else
                        obj = matlab.net.internal.copyParamsToProps(obj, varargin);
                    end
                end
            end
        end
        
        function set.Scope(obj, value)
            import matlab.net.internal.*
            if isempty(value)
                obj.Scope = matlab.net.URI.empty;
            elseif isa(value, 'matlab.net.URI')
                obj.Scope = value;
            else
                value = getStringVector(value, mfilename, 'Scope');
                res = arrayfun(@matlab.net.URI.assumeHost, value, 'UniformOutput', false);
                obj.Scope = [res{:}];
            end
        end
       
        function set.Realm(obj, value)
            import matlab.net.internal.*
            if isempty(value)
                obj.Realm = [];
            else
                obj.Realm = getStringVector(value, mfilename, 'Realm');
            end
        end
        
        function set.Scheme(obj, value)
            import matlab.net.internal.*
            if isempty(value)
                obj.Scheme = [];
            elseif isa(value, 'matlab.net.http.AuthenticationScheme')
                obj.Scheme = value;
            else
                value = getStringVector(value, mfilename, 'Scheme', true, ...
                                        'matlab.net.http.AuthenticationScheme');
                obj.Scheme = matlab.net.http.AuthenticationScheme(value);
            end
        end
        
        function set.Username(obj, value)
            import matlab.net.internal.*
            if ~isempty(value)
                value = getString(value, mfilename, 'Username');
            else
            end
            obj.Username = value;
        end
        
        function set.Password(obj, value)
            import matlab.net.internal.*
            if ~isempty(value)
                value = getString(value, mfilename, 'Password');
            else
            end
            obj.Password = value;
        end
        
        function set.GetCredentialsFcn(obj, value)
            if ~isempty(value)
                validateattributes(value, {'function_handle'}, {'scalar'}, ...
                                   mfilename, 'GetCredentialsFcn');
                if (nargin(value) >= 0 && nargin(value) < 3) || ...
                        (nargout(value) >= 0 && nargout(value) < 2)
                    error(message('MATLAB:http:GetCredentialsFcnError', ...
                        nargin(value), nargout(value), 3, 1));
                else
                end
            else
            end
            obj.GetCredentialsFcn = value;
        end
    end
    
    methods (Access={?matlab.net.http.RequestMessage,?tHTTPCredentialsUnit})
        function cred = getCredentials(obj, uri, authInfos)
        % getCredentials - get Credentials object in a vector of Credentials objects, 
        %   choosing the one with the best match for the strongest scheme.
        %
        %   obj       array of Credentials
        %   uri       URI of request
        %   authInfos vector of AuthInfos (challenges) in the response message; empty 
        %             if no challenge received yet, in which case we choose the best
        %             matching credential based on URI and scheme only
        %   cred      the Credentials object that was matched (it is a handle)
        %
        % Returns [] if there is no match.
        %
        % This function is designed to be called in 2 cases
        %   1. After an "unauthorized" response from a server indicating that
        %      authentication failed or was required. The uri is the URI of the
        %      request message and the authInfos is information in the server's
        %      response message containing the WWW-Authenticate or Proxy-Authenticate
        %      AuthenticationField contents. In this case we search the Credentials 
        %      in obj array for a match of uri and authInfos and return the cred.
        %   2. Before any send other than a retry after an "unauthorized" response.
        %      This is to determine if we have previously successfully authenticated
        %      with the server or proxy to be contacted, using one of the Credentials
        %      objects in obj, or to determine whether to proactively send
        %      credentials in a request using Basic authentication. In this case the
        %      uri is the URI of the request and authInfo is empty. 
        %
        % Matching algorithm looks at these matches, where an empty value on the
        % right matches anything on the left, and an empty value on the left only
        % matches an empty value on the right. All these have to match in order for
        % a Credential to be selected.
        %
        %      authInfo.Scheme in obj.Scheme (if authInfo specified)
        %      uri.Host        == obj.Scope.Host, anchored to end of uri.Host
        %      uri.Path        == obj.Scope.Path, anchored to start of uri.Path
        %    if authInfo set:
        %      authInfo.Realm  == obj.Realm, general regexp
        %    
        % In case of multiple matches, the most specific (highest priority) match in
        % the first field above wins. If there is more then one most specific match
        % in the first matching field, then the most specific in the next field down
        % wins, etc. By "most specific" we mean "longest", except that a match with
        % an empty on the right is considered least specific. If there are multiple
        % equally specific matches, we return the one with the strongest Scheme
        %
        % If authInfo is a vector naming different Schemes, do the above search
        % first with the strongest Scheme (Digest > Basic).
        %
        % For example, for the uri www.internal.mathworks.com/foo/bar the following
        % Scopes match, from most specific to least:
        %
        %                                  uri.Host==Scope.Host  uri.Path==Scope.Path
        %    internal.mathworks.com/foo/bar       full                 full
        %    internal.mathworks.com/foo           full                 partial
        %    internal.mathworks.com               full                 empty
        %    mathworks.com/foo/bar                partial              full
        %    mathworks.com/foo                    partial              partial
        %    mathwork s.com                       partial              empty
        %    /foo/bar                             empty                full
        %    /foo                                 empty                partial
        %    empty                                empty                empty
        
            import matlab.net.http.*
            if isempty(authInfos)
                cred = getCredentialsInternal(obj, uri, authInfos, []);
            else
                cred = getCredentialsInternal(obj, uri, ...
                                            authInfos, AuthenticationScheme.Digest);
                if isempty(cred)
                    cred = getCredentialsInternal(obj, uri, ...
                                            authInfos, AuthenticationScheme.Basic);
                else
                end
            end
        end
        
        % addProxyCredInfo Add candidate proxy Credential info to Credentials
        %   This is used to add a CredentialInfo for a proxy that might require
        %   authentication, whose username and password came from someplace like
        %   preferences, prior to getting a challenge from a server. This
        %   CredentialInfo has an empty AuthInfo, which we set when choosing this
        %   in response to a challenge. 
        function addProxyCredInfo(obj, proxyURI, username, password)
            credInfo = matlab.net.http.internal.CredentialInfo([], proxyURI, ...
                                                          username, password, true);
            obj.addCredInfo(credInfo, false);
        end
        
        function credInfo = createCredInfo(obj, uri, req, resp, authInfos, ...
                                           forProxy, prevCredInfo, usePrevCredInfo)
        % createCredInfo Create a new CredentialInfo as a candidate to be
        %   added to this Credentials object, choosing the strongest Scheme supported
        %   by both this object and authInfos, that has a matching Realm. Caller
        %   should try to authenticate using this returned credInfo, and if
        %   successful, caller should call addCredInfo(credInfo, true) to add it.
        %
        %   We always call the GetCredentialsFcn, if set. Otherwise we use the
        %   Username and Password in this object. In this case, if authentication
        %   using credInfo fails, caller might want to reinvoke this function, in
        %   case the GetCredentialsFcn is interacting with the user and wants to give
        %   the user another chance to type a good name and password.
        %
        %   We don't check that the Scope of this Credentials is appopriate for the
        %   uri -- that is normally done by the caller who chose this Credentials
        %   object. 
        %
        %   prevCredInfo initially empty. If set, this is the previous credInfo
        %                that we tried to authenticate with but failed, or which we
        %                never tried. 
        %
        %   usePrevCredInfo true if we never tried to use prevCredInfo, so use the
        %                username/password in it to make the new CredInfo instead of
        %                that in this Credentials object. This happens when the
        %                infrastructure created the prevCredInfo proactively prior to
        %                responding to any challenge based on information such as
        %                the username/password in the proxy preferences panel.
        %
        %   credInfo   empty if we can't create a CredentialInfo because this
        %              Credentials doesn't allow the Scheme or realm in any
        %              authInfos. Returns the number 0 if we couldn't get either a
        %              username or password because neither were set in this object
        %              and GetCredentialsFcn was unspecified or returned [] for
        %              username.
        %
        
            import matlab.net.http.*
            import matlab.net.http.internal.*
            
            assert(~isempty(authInfos));
            schemeMatch = @(scheme) isempty(obj.Scheme) || ...
                  (any(getSchemes(authInfos) == scheme) && any([obj.Scheme] == scheme));
            % look for Scheme match, first Digest and then Basic
            index = find(schemeMatch(AuthenticationScheme.Digest));
            if isempty(index)
                index = find(schemeMatch(AuthenticationScheme.Basic));
                if isempty(index)
                    credInfo = [];
                    return;
                else
                end
            else
            end
            authInfo = authInfos(index);    
            % If we have a Realm, use authInfo only if authInfo.realm matches or is
            % empty
            realm = authInfo.getParameter('realm');
            if ~isempty(obj.Realm) && ~isempty(realm)
                matches = regexp(realm, obj.Realm, 'once');
                if isempty(matches) || (iscell(matches) && ~any([matches{:}]))
                    credInfo = [];
                    return;
                else
                end
            else
            end
                
            if isempty(obj.GetCredentialsFcn)
                if usePrevCredInfo
                    username = prevCredInfo.Username;
                    password = prevCredInfo.Password;
                else
                    username = obj.Username;
                    password = obj.Password;
                end
            else
                fcn = obj.GetCredentialsFcn;
                if ~isempty(prevCredInfo)
                    args = {obj, req, resp, authInfo, prevCredInfo.Username, ...
                            prevCredInfo.Password};
                else
                    args = {obj, req, resp, authInfo, [], []};
                end
                % only call fcn with number of args it supports, unless it takes
                % varargin
                fcnArgs = min(nargin(fcn),length(args));
                if fcnArgs >= 0
                    [username, password] = fcn(args{1:fcnArgs});
                else
                    [username, password] = fcn(args{:});
                end
                username = string(username); 
                password = string(password);
            end
            if isempty(username) && ~ischar(username)
                % a username of [], not '' or "" means don't attempt authentication
                credInfo = 0;
            else
                credInfo = CredentialInfo(authInfo, uri, username, password, forProxy);
            end
        end
        
        function addCredInfo(obj, credInfo, force)
        % addCredInfo Add the credInfo to this object's CredentialInfos
        %   This is called after a successful authentication using credInfo, to add
        %   the credInfo to the CredentialInfos so it can be used again for a future
        %   authentication, or to adjust existing credentials that would work for
        %   this credInfo. The LastUsed time is updated in any credInfo added or
        %   adjusted.
        %
        %   The force flag applies only to basic.
        %
        %   If credInfo.Scheme is anything other than Basic, or force is true,
        %   unconditionally add the this credInfo to the end of the list. In the
        %   non-Basic case, this likely means the credInfo was using Digest, and its
        %   URIs is either one URI equal to the URI of the authenticated request that
        %   prompted its creation or its URIs are a vector of absolute URIs
        %   corresponding to all of the URIs in the credInfo.AuthInfo.domain array.
        %   In the Basic/force case, this means that we already tried to proactively
        %   authenticate using all existing CredentialInfos that satisfied the prefix
        %   match, but none worked, or there was no prefix match, so this
        %   new one needs to be added unconditionally, or replace an existing one
        %   with the identical URI and realm. For example, for /foo/bar we tried to
        %   use an existing /foo, but that failed, so we need to add /foo/bar. If
        %   there was previously a /foo and /foo/bar that both failed, we'll replace
        %   the existing /foo/bar if its realm matches.
        %
        %   If credInfo.Scheme is Basic and force is false, it means we found an
        %   existing CredentialInfo whose URI matched the prefix of the request URI,
        %   and tried to authenticate with it, but it failed, so we created a new
        %   CredentialInfo which worked. If that new CredentialInfo has a URI that
        %   exactly matches any existing Basic CredentialInfo, replace the existing
        %   one. This likely means the username or password changed, which was the
        %   reason for the failure. If that new one shares a common prefix with an
        %   existing one, with the same realm and username/password it means we could
        %   have used the existing one, but didn't do so because the prefix match
        %   failed. In this case chop the existing one with the longest common prefix
        %   match at the common prefix and don't add the new one. If there is more
        %   than one such match, use the most recently used. This handles the case
        %   where an existing /foo/bar has the same credentials as /foo/baz: we trim
        %   the existing one to /foo so that a future reference to /foo/fat will
        %   proactively try to use the same credentials. (If it fails because the
        %   username or password is different, we'll store the new one for /foo/fat.)
        %   If there is no commo prefix, add the new one. A common prefix match
        %   includes one with no path at all (i.e., the root).
        
            import matlab.net.http.AuthenticationScheme
            if force || (isempty(credInfo.AuthInfo) || ...
                 credInfo.AuthInfo.Scheme ~= AuthenticationScheme.Basic) || ...
                 isempty(obj.CredentialInfos)
                obj.CredentialInfos(end+1) = credInfo;
            else
                % Basic and not force
                maxCredInfo = []; % handle to best matching CredentialInfo
                maxLength = 0;
                for i = 1 : length(obj.CredentialInfos)
                    % Check if the candidate CredentialInfo matches the one we were
                    % given, with the same username/password and realm. If so,
                    % remember the one with the longest URI match.
                    testInfo = obj.CredentialInfos(i);
                    if testInfo.AuthInfo.Scheme == AuthenticationScheme.Basic && ...
                       credInfo.appliesTo(testInfo) && ...
                       matchInfoRealms(testInfo.AuthInfo, credInfo.AuthInfo)
                        % Since credInfo and testInfo are Basic, we know URIs has
                        % just one entry
                        len = credInfo.URIs.matchLength(testInfo.URIs);
                        if len > maxLength
                            maxLength = len;
                            maxCredInfo = testInfo;
                        else
                        end
                    else
                    end
                end
                if maxLength > 0
                    % found the best match; trim it down
                    maxCredInfo.chopCommonPrefix(credInfo.URIs);
                    credInfo = maxCredInfo;
                else
                    % Didn't find a match, so add it
                    obj.CredentialInfos(end+1) = credInfo;
                end
            end
            
            % update LastUsed date for this added or modified credInfo
            credInfo.LastUsed = datetime('now');

            function tf = matchInfoRealms(a1, a2)
            % match optional realm fields in two AuthInfos. If both fields missing,
            % it's a match.
                r1 = a1.getParameter('realm');
                r2 = a2.getParameter('realm');
                tf = (isempty(r1) && isempty(r2)) || isequal(r1,r2);
            end
        end
        
        function credInfos = getCommonPrefixCredInfos(obj, uri)
        % Return all credInfos having a URI that matches everything up to, but not
        % including, Path
            if ~isempty(obj.CredentialInfos)
                credInfos = obj.CredentialInfos.commonPrefix(uri);
            else
                credInfos = [];
            end
        end
        
        function [credRes, credInfoRes] = getBestCredInfo(obj, uri, authInfo, forProxy)
        % getBestCredInfo Find best matching CredentialInfo for URI
        %   Searches across all CredentialInfos obj array of Credentials, returning
        %   the one with the longest match of URI to prefix of uri and the
        %   Credentials object containing it. In case of tie, returns the one most
        %   recently used. Prefix match requires all fields through Port to be
        %   exactly the same, and then 0 or more Path segments.
        %
        %   If authInfo is unset, this function is being used to find a
        %   CredentialInfo that we used before, to proactively authenticate without
        %   first getting a challenge. This is appropriate for Basic authentication,
        %   and for Digest authentication after having responded to an earlier
        %   challenge. In this case, we choose the CredentialInfo with the strongest
        %   AuthInfo.Scheme first and then with longest uri match (but it has to
        %   match at least the host in the uri).
        %
        %   If authInfo is set, this is being called after having received a
        %   challenge. In this case we only look at CredentialInfos whose AuthInfo
        %   applies to the challenge authInfo.
        %
        %   forProxy   if set, look only in CredentialInfos where ForProxy is set
        %              if unset or missing, look only in CredentialInfos where
        %              ForProxy is not set.
        
        %   Returns the CredentialInfo and its containing Credentials
            matchLen = 0; % length of longest match for strongest scheme
            credRes = [];
            credInfoRes = [];
            maxScheme = -1;  % numeric value of AuthInfo.Scheme we found
            if nargin < 4
                forProxy = false;
            else
            end
                
            for i = 1 : length(obj)
                cred = obj(i);
                for j = 1 : length(cred.CredentialInfos)
                    credInfo = cred.CredentialInfos(j);
                    % get scheme in AuthInfo as an absolute number
                    if ~isempty(credInfo.AuthInfo) 
                        scheme = abs(credInfo.AuthInfo.Scheme);
                    else
                        % only proxy credInfos have no AuthInfo
                        assert(credInfo.ForProxy)
                        scheme = 0;
                    end
                    % If authInfo is set, don't look at Scheme in credInfo;
                    % otherwise look only at strongest Scheme first. If
                    % credInfo.AuthInfo is empty, use it only if we don't already
                    % have maxScheme.
                    if credInfo.ForProxy == forProxy && ...
                       (isempty(credInfo.AuthInfo) || ...
                          credInfo.AuthInfo.worksFor(authInfo)) && ...
                       (~isempty(authInfo) || ...
                          (isempty(credInfo.AuthInfo) && maxScheme < 0) || ...
                          scheme >= maxScheme)
                        % the credInfo applies to authInfo (or its credInfo.AuthInfo
                        % is empty), or authInfo is empty and this credInfo is the
                        % equal to or stronger than maxScheme
                        for k = 1 : length(credInfo.URIs)
                            testURI = credInfo.URIs(k);
                            len = testURI.matchLength(uri);
                            % Use this credInfo if:
                            %   scheme same as maxScheme: it has a longer match
                            %      or its match is equal and it was more recently
                            %      used
                            %   scheme greater than maxScheme: it matches any part
                            if (scheme == maxScheme && ...
                                (len > matchLen) || ...
                                (len == matchLen && ...
                                 (~isempty(credInfoRes) && ...
                                  credInfo.LastUsed > credInfoRes.LastUsed))) || ...
                               (scheme > maxScheme && len > 0)
                                matchLen = len;
                                credRes = cred;
                                credInfoRes = credInfo;
                                if ~isempty(credInfo.AuthInfo)
                                    maxScheme = scheme;
                                else
                                end
                            end
                        end
                    else
                    end
                end
            end
            if ~isempty(credInfoRes) && isempty(credInfoRes.AuthInfo)
                % If the chosen credInfo doesn't have an AuthInfo, set it to the
                % one we matched. This only applies if the credInfo was inserted by
                % addProxyCredInfo.
                credInfoRes.AuthInfo = authInfo;
            end
        end
        
        function delete(obj, credInfo)
        % delete the credInfo from this object
            contains = obj.CredentialInfos == credInfo;
            assert(any(contains))
            obj.CredentialInfos(contains) = [];
        end
    end
    
    methods (Access=protected, Hidden)
        function cpObj = copyElement(obj)
        % Overridden to copy everything except the CredentialInfos handles.
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            cpObj.CredentialInfos = matlab.net.http.internal.CredentialInfo.empty;
        end
    end
    
    methods (Access=private)
        function cred = getCredentialsInternal(obj, uri, authInfos, authScheme)
        % Implementation of getCredentials. If there are challenges (authInfos) only
        % get credentials that match the challenge for the specified authScheme. If
        % there are no challenges ignore authScheme and get the best matching
        % credentials for the strongest scheme. We don't use req or resp but pass
        % them into the GetCredendialsFcn if necessary. 
        %
        % Note obj is vector of Credentials
        
        % TBD this function badly needs decomposing.
            cred = [];
            
            % get the one AuthInfo we should look at, if any
            if isempty(authInfos)
                authInfo = [];
            else
                % only look at specified authScheme, and pick only the first matching
                % authInfo
                authInfos = authInfos(getSchemes(authInfos) == authScheme);
                % if no authInfo for the authScheme, we're done
                if isempty(authInfos) 
                    return
                else
                end
                authInfo = authInfos(1);
            end
            
            function res = getMatching(schemes)
            % Return Schemes in schemes that match those in authInfo
                if isempty(authInfo)
                    res = schemes;
                else
                    res = intersect(authInfo.Scheme, schemes);
                end
            end

            % If authScheme specified, first find best Credentials whose Scheme
            % contains authScheme. If none, look at Credentials with empty Scheme
            % (which matches anything). If authScheme not specified, just find best
            % Credentials based on other criteria, picking the one with strongest
            % Scheme only if there's a tie.
            comparator{1} = @(c) ismember(authScheme, [c.Scheme]);
            comparator{2} = @(c) isempty(c.Scheme);
            for ci = 1 : length(comparator)
                if ci > 1 && isempty(authScheme)
                    % 1st comparator done; If authScheme is empty, we already
                    % looked at all creds, so no need to run through 2nd comparator
                    break
                else 
                end
                if ~isempty(authScheme)
                    % If authScheme specified, work only on creds that have matching
                    % schemes with authScheme. 
                    creds = obj(arrayfun(comparator{ci}, obj));
                    if isempty(creds)
                        % None of the creds have a matching scheme
                        continue
                    else % else clause included so that profiler gets to end statement
                    end
                else
                    % No authScheme specified, then look at all creds
                    creds = obj;
                end
                
                % The schemes in all creds match authScheme, or authScheme is empty

                % Get array of credentials matching Scope.Host and uri.Host with the
                % same Port. This will also match ones with empty scope.
                host = uri.Host; 
                port = uri.Port;
                % Lauren's inline conditional: iif(cond1,act1,cond2,act2,...,true,default)
                iif = @(varargin) varargin{2*find([varargin{1:2:end}], 1)}();

                % Function returning the priority of the match of uri.Host to sHost,
                % anchored to end of string. Priority is:
                %    no match     -1
                %    empty        0
                %    match        number of matching characters
                % The idea is that an empty sHost matches any uri.Host, but gets
                % lower priority than an actual match. In addition, if sPort isn't
                % empty, it has to match port exactly.
                hostMatcher = @(sHost, sPort) iif( ...
                   isempty(sHost),    0, ...
                   (isempty(sPort) || isequal(port,sPort)) && ~isempty(sHost) && ...
                       ~isempty(regexp(host, matlab.net.internal.getSafeRegexp(sHost) + '$','once')), ...
                                          @()strlength(sHost), ... 
                   true,             -1); 
                % Function that takes a scope (array of URIs) and returns the max
                % priority of the match of any of scope.Host fields, based on
                % hostMatcher. Returns 0 if scope is empty. We need to use {scope.Host}
                % instead of [scope.Host] so that empty values get passed into
                % hostMatcher.
                hostScopeMatcher = @(scope) iif( ...
                    isempty(scope), 0, ...
                    true,           @()max(cellfun(hostMatcher, {scope.Host}, {scope.Port})));
                % Pass in each Scope array to hostScopeMatcher and get priority of
                % each. Result is a array of numbers. 
                priorities = cellfun(hostScopeMatcher, {creds.Scope});
                
                % Sort creds and matches by priority, high to low
                [~,indices] = sort(priorities);
                indices = fliplr(indices); 

                creds = creds(indices);    
                
                % Now creds is vector of Credentials whose URIs have have a Host and
                % Port that matches the uri Host and Port, and
                % priorities(i) is priority of Host match in creds(i). It will be
                % something like:
                %   15 15 15 10 10 2 2 2 2 0 -1 -1 -1
                % which says that:
                %   creds(1:3) prioirty 15: match 15 characters
                %   creds(4:5) priority 10: match 10 characters
                %   creds(6:9) priority 4:  match 4 characters
                %   creds(10)  priority 0:  no host specified in creds (matches any)
                %   creds(11:13) don't match
                % and the rest don't match.
                priorities = priorities(indices); 
                path = uri.EncodedPath;

                % Now do Path matching.
                % Go through each block of creds that has an equal value of host
                % priority and choose the one with the longest match of uri.Path to
                % creds.Scope.Path, and then longest realm match. In the example
                % above we first go through all the 15's looking for the longest Path
                % and realm match, then the 10's, then 2's and finally the 0.
                % We only jump to the next block of priorities if there was no Path
                % and realm match in the previous block.
                blockIndex = 1;
                matchIndex = 0;
                while priorities(blockIndex) >= 0
                    % Work on the block of equal priorities(blockIndex) beginning at
                    % blockIndex: these are all creds with same length of matching
                    % host.
                    matchIndex = 0;      % index of best Scope.Path/Realm in creds so far
                    pathPriority = -2;   % priority of Path match at matchIndex
                    realmPriority = -1;  % priority of Realm match at matchIndex
                    hostPriority = priorities(blockIndex); % Host priority we're working on
                    % Advance to end of block, looking for
                    % match with Path and then Realm
                    for j = blockIndex : length(creds)
                        if priorities(j) ~= hostPriority
                            % j has gotten to the next block
                            assert(priorities(j) <= hostPriority); % expect decreasing
                            break % advance to next block
                        else % else clause included so that profiler gets to end statement
                        end
                        % work on this block of creds with same hostPriority;
                        % first see if creds.Scope.Path matches path
                        scope = creds(j).Scope;
                        % set pathLen to priority of path match: length of longest
                        % match or 0 for any empty match
                        if isempty(scope)
                            pathLen = 0;
                        else
                            pathMatcher = @(sPath) iif( ...
                               strlength(sPath) == 0, 0, ...
                               ~isempty(regexp(path, '^' + matlab.net.internal.getSafeRegexp(sPath),'once')), ...
                                               @()strlength(sPath), ... 
                               true,           -1); 
                            pathLen = max(cellfun(pathMatcher, {scope.EncodedPath}));
                            if pathLen < 0
                                % none of the Paths in this cred match; go to next
                                % cred in block
                                continue 
                            else 
                            end
                            % pathLen is legnth of path match
                        end
                        if pathLen >= pathPriority
                            % a path match with greater or equal priority to the
                            % previous one, then go on to check realm. Set rlen to
                            % Realm match priority.
                            rlen = matchRealm(creds(j).Realm, iif, authInfo);
                            if rlen < 0
                                continue % alas, none of the Realms match; skip cred
                            else 
                            end
                            % At least one realm matches, with highest priority rlen. 
                            
                            % This function, given two vectors or AuthenticationScheme returns true if a is
                            % nonempty and has an equal or larger value than any in vector b, looking only at
                            % the elemens of a and b that are contained in authInfo.Scheme. The latter is
                            % needed because we don't care if one Credentials specifies Basic while another
                            % specifies [Digest,Basic], if only Basic is allowed by the AuthInfo. We use >=
                            % instead of > in order to choose the last match when all other things are
                            % equal. The last match is actually the first one in the original Credentials
                            % array because of fliplr call above that reordered Credentials from high to low
                            % priority, causing a string of equal ones to be artificialy reversed.
                            aGTEb = @(a,b) ~isempty(a) && ...
                                             (isempty(b) || ...
                                              max(getMatching(a)) >= max(getMatching(b)));
                            if pathLen > pathPriority || ...
                               (pathLen == pathPriority && ...
                                (rlen > realmPriority || ...
                                 (rlen == realmPriority && ...
                                  aGTEb(creds(j).Scheme, creds(matchIndex).Scheme))))
                                % A path match and it is higher priority than the
                                % previous one; or the same priority and its realm
                                % match is higher; or the realm match is equal but
                                % the scheme is better or equal. Save it and the 
                                % priority of its Realm match.
                                pathPriority = pathLen;
                                matchIndex = j;
                                realmPriority = rlen;
                            else
                            end
                            % if path match is the same but realm match is shorter,
                            % or realm is equal and scheme is not better, ignore and
                            % keep going to next cred
                        else 
                            % if path match is shorter than longest so far, ignore
                            % cred
                        end
                    end
                    % we got to the end of creds in this block
                    if matchIndex > 0 || (matchIndex == 0 && j == length(creds))
                        % we got a match, or there was no match and we got to the end
                        % of all the blocks, so we're done
                        break % we're done
                    else
                        % go to next block
                        blockIndex = j;
                    end
                end
                if matchIndex > 0
                    % we found a match with this comparator
                    cred = creds(matchIndex);
                    break  % we're done
                else
                end
            end % advance to next comparator for authScheme
        end % function getCredentialsInternal
    end % methods(Access=private)
    
    methods (Access = protected)
                
        function group = getPropertyGroups(obj)
        % Provide a custom display for the case in which obj is scalar
        % Display Scheme and Scope as strings. 
        % If Password is non-empty, replace each character with '*'.
            
            group = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            if isscalar(obj)
                scheme = group.PropertyList.Scheme;
                if ~isscalar(scheme) && ~isempty(scheme)
                    scheme = strjoin(arrayfun(@char,scheme,'UniformOutput',false),...
                                     ', ');
                    group.PropertyList.Scheme = scheme;
                else
                end
                scope = strjoin(arrayfun(@char, group.PropertyList.Scope, ...
                                         'UniformOutput',false),...
                                 ', ');
                group.PropertyList.Scope = scope;
                password = group.PropertyList.Password;
                if ~isempty(password)
                    pw(1:strlength(password)) = '*';
                    group.PropertyList.Password = string(pw);
                else
                end
                % make empty fields look like []
                names = fieldnames(group.PropertyList);
                for i = 1 : length(names)
                    name = names{i};
                    if isempty(group.PropertyList.(name))
                        group.PropertyList.(name) = [];
                    else
                    end
                end
            end
        end
    end
    
    methods (Access=?tHTTPCredentialsUnit)
        function credInfos = getCredInfos(obj)
        % Test API only.
            credInfos = obj.CredentialInfos;
        end
    end
end

function rlen = matchRealm(realms, iif, authInfo)
% match array of realms to authInfo, returning priority of longest match or -1
    
    if isempty(realms) || isempty(authInfo) || isempty(authInfo.getParameter('realm'))
        rlen = 0; % empty Realm matches anything, lowest priority
    else
        realm = authInfo.getParameter('realm');
        if isempty(realm)
            rlen = 0;
        else
            match = @(r) regexp(realm, r, 'once');
            % matcher returns first and last of each match, or [0,-1]
            % if no match
            realmMatcher = @(sRealm) iif( ...
                isempty(match(sRealm)),  @()deal(0,-1), ...
                strlength(sRealm) == 0 && strlength(realm) == 0, @()deal(0,0), ...
                true,                    @()match(sRealm));
            [first, last] = arrayfun(realmMatcher, realms);
            rlen = max(last - first);
            if rlen < 0
                % no Realm matches
                rlen = -1;
            else
            end
        end
    end
end

function schemes = getSchemes(authInfos)
% Given an AuthInfo array, return an array of AuthenticationSchemes in them,
% skipping the ones whose Scheme is a string
    schemes = matlab.net.http.AuthenticationScheme.empty;
    for i = 1 : length(authInfos)
        scheme = authInfos(i).Scheme;
        if isa(scheme, 'matlab.net.http.AuthenticationScheme')
            schemes(end+1) = scheme; %#ok<AGROW>
        else
        end
    end
end

