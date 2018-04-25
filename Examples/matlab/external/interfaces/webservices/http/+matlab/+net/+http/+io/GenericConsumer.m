classdef GenericConsumer < matlab.net.http.io.ContentConsumer
% GenericConsumer Consumer for multiple content types in HTTP messages.
%
%   Use this consumer to handle streaming for multiple content types when you
%   cannot predict in advance which types the server will return. In
%   arguments to this object's constructor you specify a list of content types
%   and the ContentConsumer for each type, and then specify this
%   GenericConsumer object as the CONSUMER in your call to
%   RequestMessage.send. When the header of a response arrives, this consumer
%   uses the ContentTypeField in the response message to determine which
%   consumer in the list to invoke.
%
%   Like all ContentConsumers, GenericConsumer is a handle object that
%   modifies internal state as it is used. It is reusable and restartable.
%
%   GenericConsumer methods:
%     GenericConsumer             - constructor
%
%   For subclass authors
%   --------------------
%
%   When this consumer has chosen a delegate based on the Content-Type of the
%   message, it invokes the delegateTo method to initialize the delegated consumer and
%   its properties, and if the consumer accepts the message, invokes its start
%   method and delegates subsequent putData calls. At the end of the message,
%   it copies the delegate's Response.Body to this consumer's Response, which in
%   turn becomes the RESPONSE returned by RequestMessage.send.
%
%   GenericConsumer methods:
%     start                       - start transfer
%     putData                     - store buffer of data
%
%   GenericConsumer properties:
%     PutMethod                   - handle to current putData method
%     CurrentDelegate             - the current delegate, if a ContentConsumer
%
% See also ContentConsumer, matlab.net.http.RequestMessage,
% matlab.net.http.ResponseMessage, ContentTypeField, delegateTo

% Copyright 2017 The MathWorks, Inc.
    
    properties (Access=protected, Dependent)
        % PutMethod - handle to current putData method
        %   This is set to the current delegate's putData method, or, the PUTHANDLE
        %   function specified in the call to the constructor. This property is set by
        %   delegateTo. Subclasses should invoke this function in their putData method
        %   to send data to the delegate or to end the delegate's portion of the data
        %   by sending uint8.empty:
        %        [len, stop] = obj.PutMethod(data);
        %
        %   At the end of the message, after the above call to any delegate to end the
        %   message, subclasses should set PutMethod to empty and invoke the call
        %   putData(uint8.empty) in their superclass so that this class knows the
        %   message has ended. This putData call will leave PutMethod empty or set it
        %   back to the PUTHANDLE.
        % 
        % See also delegateTo, CurrentDelegate, GenericConsumer.GenericConsumer, putData
        PutMethod       
    end

    properties (Access=private)
        Type2Consumer struct                % map of type to consumer
        PutHandle function_handle           % put handle provided to constructor, never modified
        CurrentPutMethod function_handle    % the actual PutMethod; cleared when PutMethod cleared
                                            % and reset to PutHandle at end of message
    end
    
    properties (Constant, Access=private)
        % These consumers get added to the end of the list that the caller provides to
        % the constructor.
        DefaultConsumers = struct('Type',{'^multipart/.*$','^image/.*$','^.*/.*json.*$','^.*$','^.*$'},...
                                  'Consumer',{@matlab.net.http.io.MultipartConsumer,...
                                              @matlab.net.http.io.ImageConsumer,...
                                              @matlab.net.http.io.JSONConsumer,...
                                              @matlab.net.http.io.StringConsumer,...
                                              @matlab.net.http.io.BinaryConsumer});
    end

    methods 
        function set.PutMethod(obj, value)
        % Only allow empty to be set
            if isempty(value)
                obj.CurrentPutMethod = function_handle.empty;
            else
                error(message('MATLAB:http:CannotSetPutMethod'));
            end
        end
                
        function value = get.PutMethod(obj)
            value = obj.CurrentPutMethod;
        end
                
        
        function obj = GenericConsumer(varargin)
        % GenericConsumer Generic ContentConsumer for streaming HTTP responses
        %   GENCONSUMER = GenericConsumer(TYPES1, CONSUMER1, TYPES2, CONSUMER2, ...)
        %   constructs a GenericConsumer to handle the specified TYPES. TYPES is a
        %   string array, character vector, or cell array of character vectors that
        %   specifies content types using the syntax "type/subtype", and CONSUMER is
        %   an instance of any ContentConsumer that can handle one of the specified
        %   types, or a handle to a function returning a ContentConsumer that can
        %   handle those types. If you specify no arguments, a default set of consumers
        %   is used (see below).
        %
        %   The type and subtype components in each element of TYPES are treated as
        %   regular expressions, matched against the type/subtype of the
        %   ContentTypeField in the response, with the addition that a lone '*' for a
        %   type or subtype matches any type or subtype, and all searches are anchored
        %   to both the start and end of the string. For example,
        %
        %      text/*      matches type 'text' and any subtype
        %      */.*json.*  matches any type with subtype that contains 'json'.
        %      */.*json    matches any type with subtype that ends with 'json'.
        %      */*         matches any type or subtype.
        %
        %   If the subtype is '*', you may omit the trailing '/*':
        % 
        %      text        same as 'text/*'
        %
        %   TYPES are searched in order they appear, and the first match is used. If
        %   there are no matches among the specified types, a default set of consumers
        %   is used, depending on the type, in this order:
        %       
        %      multipart/*     MultipartConsumer
        %      image/*         ImageConsumer
        %      .*/.*json.*     JSONConsumer
        %      */*             StringConsumer
        %      */*             BinaryConsumer
        %
        %   While both StringConsumer and BinaryConsumer are used for any type,
        %   StringConsumer will only accept types for which it can determine a charset:
        %   text/*, any type with a charset attribute, or one of the types MATLAB knows
        %   is character-based, such as application/xml and application/javascript. If
        %   StringConsumer rejects the type, BinaryConsumer accepts any type and just
        %   stores the unconverted payload in Response.Body.Data as a uint8 vector.
        %
        %   When this consumer chooses a matching delegate based on the above search,
        %   it invokes the delegate's initialize method to see if the delegate is
        %   willing to accept the payload. If the method returns false to indicate
        %   that the delegate does not accept, then this consumer continues searching
        %   the list as above to find the next matching delegate.
        %
        %   GENCONSUMER = GenericConsumer(PUTHANDLE) constructs a ContentConsumer that
        %   calls PUTHANDLE for each call to this consumer's putData method. PUTHANDLE
        %   must be a handle to a function that can be called using the syntax of
        %   ContentConsumer.putData:
        %     [LENGTH, STOP] = putData(data)
        %   which accepts a uint8 array as input and returns the LENGTH of data that it
        %   processed and a STOP indicator. Use this syntax when you simply want to
        %   process all input from the server using a particular function, when you know
        %   the type of data that the server will return. The function will not have
        %   access to the ResponseMessage or any information about this consumer.
        %
        % See also ContentConsumer, matlab.net.http.field.ContentTypeField,
        % initialize, putData, regexp, Response, MultipartConsumer, ImageConsumer,
        % JSONConsumer, StringConsumer, BinaryConsumer
            if nargin == 1 && isa(varargin{1},'function_handle')
                % if the only arg is a function handle, it must support the syntax of
                % ContentConsumer.putData, with at least one input and 2 output arguments 
                arg = varargin{1};
                if nargin(arg) == 0 || nargout(arg) == 0 || nargout(arg) == 1
                    error(message('MATLAB:http:BadPutDataMethod'));
                end
                validateattributes(arg, {'function_handle'}, {'scalar'}, mfilename, 'PUTHANDLE');
                obj.CurrentPutMethod = arg;
                obj.PutHandle = arg;
            elseif mod(nargin, 2) ~= 0
                error(message('MATLAB:http:OddNumberOfArguments'));
            else
                obj.CurrentPutMethod = function_handle.empty;
                for i = 1 : 2 : length(varargin)
                    consumer = varargin{i+1};
                    validateattributes(consumer, {'function_handle', 'matlab.net.http.io.ContentConsumer', ...
                        'handle'}, {'scalar'}, mfilename, 'CONSUMER', i+1);
                    types = matlab.net.internal.getStringVector(varargin{i}, ...
                        'GenericConsumer', 'TYPES');
                    for j = 1 : length(types)
                        type = types(j);
                        switch count(type, '/')
                            case 0
                                % if "foo", assume "foo/*"
                                type = type + '/.*';
                            case 1
                                % replace * for type or subtype with .* so it's the intended regexp
                                if type.startsWith('/')
                                    type = '.*' + type;
                                end
                                if type.endsWith('/*') 
                                    type = type.insertBefore(strlength(type), '.');
                                elseif type.endsWith('/')
                                    type = type + '.*';
                                end
                            otherwise
                                error(message('MATLAB:http:BadMediaType', type));
                        end
                        if type.startsWith('*') 
                            type = '.' + type;
                        end
                        types(j) = '^' + lower(type) + '$';
                    end
                    % add one entry to Type2Consumer for each member of types
                    obj.Type2Consumer = [obj.Type2Consumer struct('Type',types,'Consumer',consumer)];
                end
                % add a set of default consumers to the list, if none of the user's match
                obj.Type2Consumer = [obj.Type2Consumer obj.DefaultConsumers];
            end
        end
        
        function [len, stop] = putData(obj, varargin)
        % putData Store the next block of data
        %   [LEN, STOP] = putData(CONSUMER, DATA) is an overridden method of
        %   ContentConsumer that stores the next buffer of data. If a PUTHANDLE was
        %   specified to the constructor of this object or delegateTo returned a
        %   delegate that accepted the message, calls the function in PutMethod with
        %   DATA as an argument. If there was consumer that accepted the message calls
        %   ContentConsumer.putData, which appends DATA to Response.Body.Data.
        %
        %   If DATA is [] to indicate the message has ended and there was a delegate,
        %   copies Response from the delegate to this object's Response.
        %
        % See also matlab.net.http.io.ContentConsumer.putData, delegateTo, PutMethod,
        % Response
        
        % UNDOCUMENTED BEHAVIOR FOR INTERNAL USE ONLY
        %   [LEN, STOP] = putData(CONSUMER, DATA, END) if END is false and DATA is
        %   empty, don't copy the delegate's Response to our Response and don't pass on
        %   the empty indication to our superclass. This means that the message hasn't
        %   really ended and the caller wants to deal with the delegate's data
        %   separately. Irrelevant if there is no CurrentDelegate.

        % If PutMethod (equivalently, CurrentPutMethod) isempty, and DATA is empty, 
        % resets PutMethod to the PUTHANDLE provided to the constructor.
            data = varargin{1};
            if ~isempty(obj.CurrentPutMethod)
                [len, stop] = obj.CurrentPutMethod(data);
            else
                % we have no delegate or CurrentPutMethod, call superclass to store data or end the
                % message
                [len, stop] = obj.putData@matlab.net.http.io.ContentConsumer(data);
            end
            if isempty(data) || stop
                if ~isempty(data)
                    % if consumer set stop, call once more with empty
                    obj.CurrentPutMethod(uint8.empty);
                end
                % This restores PutMethod to the PUTHANDLE, if any
                obj.CurrentPutMethod = obj.PutHandle;
                    
            end                    
            if ~isempty(obj.CurrentDelegate) && isempty(data)
                % we have a delegate at end of data, copy consumer's Response back to us and
                % tell our superclass the message ended, unless the COPY argument is false.
                copy = length(varargin) < 2 || varargin{2};
                if copy
                    obj.Response = obj.CurrentDelegate.Response;
                    len = obj.putData@matlab.net.http.io.ContentConsumer(uint8.empty);
                end
            end
        end
    end
    
    methods (Access=protected)
        function bufsize = start(obj)
        % start Start transfer of data
        %   BUFSIZE = start(CONSUMER) is an abstract method of ContentConsumer that
        %   prepares CONSUMER for receipt of data. If the constructor of this
        %   GenericConsumer was called using a putDataHandle, simply returns [].
        %   Otherwise, it determines which ContentConsumer to delegate to, based on the
        %   ContentType of the Response and TYPES arguments to this object's
        %   constructor. The delegate was specified as either a consumer instance or a
        %   function handle returning one; if a function handle, calls the function to
        %   obtain a delegate consumer instance. It then calls delegateTo, passing in
        %   the consumer instance, which calls initialize in that consumer. If
        %   initialize returns false to indicate it does not accept the message, then the
        %   next delegate in the list is tried. If a delegate accepts, it calls start in
        %   that delegate. In that case the caller of START is obligated to send that
        %   delegate the data from the message, or terminate the delegate by calling
        %   its putData(uint8.empty).
        %
        %   This method throws an exception if all delegates reject the message.
        %
        %   When a delegate accepts the message, it saves the delegate instance for that
        %   Content-Type so that if this method is called again with a Content-Type that
        %   matches the same TYPES entry, the same delegate instance is used.
        %
        % See also GenericConsumer, Response, initialize, delegateTo
            bufsize = [];
            if isempty(obj.CurrentPutMethod)
                [ok, bufsize] = obj.chooseAndInitializeDelegate(obj.Header);
                % We don't expect all delegates to reject, because the last delegate in our
                % Types2Consumer list should be BinaryConsumer, which accepts everything, and
                % users can't override this.
                % No delegate found; error. This is likely a bug because BinaryConsumer is
                % always on the list for */*.
                if ~ok
                    obj.errorOnNoMatch();
                end
            end
        end
    end
    
    methods (Access=protected, Sealed)
        function [ok, bufsize] = delegateTo(obj, delegate, header)
            [ok, bufsize] = obj.delegateTo@matlab.net.http.io.ContentConsumer(delegate, header);
            if (ok)
                obj.CurrentPutMethod = @(data)putData(obj.CurrentDelegate,data);
            else
                obj.CurrentPutMethod = function_handle.empty;
            end
        end
    end 
    
    methods (Access=?matlab.net.http.io.MultipartConsumer)
        function [ok, bufsize] = chooseAndInitializeDelegate(obj, header)
        % chooseAndInitializeDelegate chooses and initializes a delegate 
        %   [OK, BUFSIZE] = chooseAndInitializeDelegate(CONSUMER, HEADER) finds the
        %   ContentConsumer appropriate for the ContentTypeField in HEADER (a vector of
        %   HeaderField) based on the list of consumers specified in the
        %   constructor and the default list, calls the delegateTo
        %   method (defined in ContentConsumer) to initialize the delegate's properties
        %   based on this consumer's properties and HEADER, and returns the return value
        %   of the delegate's START method. It saves the delegate in
        %   CONSUMER.CurrentDelegate and also in the TYPE/CONSUMER list for reuse if a
        %   subsequent call to this method would match the same type in the list.
        %
        %   A "matching delegate" is one that was selected based on a match of the
        %   Content-Type to the list of types in Types2Consumer, which is searched in
        %   order. A delegate "accepts" the header if its INITIALIZE method returns
        %   true, indicating its willingness to process the data based on the
        %   information in HEADER.
        %
        %   If a matching delegate does not accept the header, this method continues
        %   searching Types2Consumer for another matching delegate.
        %
        %   Returns OK = true and sets CurrentDelegate to the first delegate matching
        %   delegate that accepts the header. In this case BUFIZE is the return value
        %   of the delegate's START method.
        %
        %   Returns OK = false and sets CurrentDelegate to [] if there was no matching
        %   delegate. Caller should consider this a bug, since the default list has a
        %   */* at the end.
        %
        %   Returns OK = false and sets CurrentDelegate to the first matching delegate
        %   if at least one matching delegate was found but all delegates reject the
        %   header. Caller should consider this as a bug because BinaryConsumer at the
        %   end of the list should accept everything.
        %
        %   If OK = false, BUFSIZE is not valid.
        %
        %   Caller is responsible for calling start in the delegate.
        %
        %   If this class constructor was called with a PUTHANDLE argument, this method
        %   always returns OK = true and BUFSIZE = [], and leaves properties unchanged.
        %
        % See also GenericConsumer.GenericConsumer, ContentConsumer, delegateTo,
        % CurrentDelegate, initialize, matlab.net.http.HeaderField,
        % matlab.net.http.field.ContentTypeField
        
            if ~isempty(obj.PutHandle)
                ok = true;
                bufsize = [];
                return;
            end
            ctf = header.getValidField('Content-Type');
            if isempty(ctf)
                contentType = [];
            else
                contentType = ctf(1).convert();
            end
            if isempty(contentType) || isstring(contentType)
                type = "/";
            else
                type = lower(contentType.Type + '/' + contentType.Subtype);
            end
            ok = false;
            obj.CurrentDelegate = [];
            firstDelegate = [];
            bufsize = [];
            for i = 1 : length(obj.Type2Consumer)
                match = regexp(type, obj.Type2Consumer(i).Type, 'once');
                if ~isempty(match) && (~iscell(match) || any([match{:}]))
                    % Call superclass delegateTo(), which instantiates and initializes the delegate,
                    % sets the delegate's MyDelegator to point to us, and stores the delegate in
                    % obj.CurrentDelegate.
                    delegate = obj.Type2Consumer(i).Consumer;
                    if isempty(obj.CurrentDelegate)
                        firstDelegate = delegate;
                    end
                    [ok, bufsize] = obj.delegateTo(delegate, header);
                    if (ok)
                        % If the delegate accepts the message, replace the entry in the Type2Consumer
                        % table with the delegate instance. It might have been a function handle, and
                        % we don't want to call the function to instantiate a new delegate every time we
                        % need this delegate (relevant for MultipartConsumer that may reuse the same
                        % consumer multiple times in a message).
                        obj.Type2Consumer(i).Consumer = obj.CurrentDelegate;
                        break;
                    else
                        % If the delegate does not accept the message, keep looking for more
                        % delegates. 
                    end
                end
            end
            if ~ok
                % no delegate found or all reject; save first matching delegate, if any
                obj.CurrentDelegate = firstDelegate;
            end
        end
        
        function errorOnNoMatch(obj)
        % Throw an error when we could not find a consumer matching the Content-Type
        % field, or all the consumers we found reject the content.
            ctf = obj.Header.getValidField('Content-Type');
            if isempty(ctf)
                ct = '';
            else
                ct = char(ctf.convert());
            end
            if isempty(obj.CurrentDelegate)
                % this should not be possible if */* is always at the end of our list
                error(message('MATLAB:http:ConsumerForType', ct));
            else
                error(message('MATLAB:http:AllConsumersReject', ct, class(obj.CurrentDelegate)));
            end
        end
    end
end