classdef (Abstract) ContentProvider < handle & matlab.mixin.Heterogeneous
% ContentProvider Provider for HTTP payloads
%   A ContentProvider supplies data for an HTTP RequestMessage while it is being
%   sent. A simple provider converts data from a MATLAB type to a byte stream (a
%   uint8 vector), and more complex providers can "stream" data to the server,
%   obtaining or generating the data at the same time it is being sent, thereby
%   avoiding the need to have all the data in memory prior to the start of the
%   message.
%
%   Normally, when sending data to a web service (typically in a PUT or POST
%   request), you would create a RequestMessage and insert data in the form of a
%   MessageBody object in the RequestMessage.Body property. When you send that
%   message using RequestMessage.send, MATLAB converts that data into a byte
%   stream to be sent to the server, converting it based on the Content-Type of
%   the message and the type of data in Body.Data. See MessageBody.Data for
%   these conversion rules.
%
%   Instead of inserting a MessageBody object into the RequestMessage.Body, you
%   can create a ContentProvider object and insert that instead. Then, when you
%   send the message, MATLAB will call methods in the ContentProvider to obtain
%   buffers of data to send, while the message is being sent.
%
%   Whether you insert a MessageBody or a ContentProvider into the message, the
%   call to RequestMessage.send does not return (i.e., is blocked) until the
%   entire message has been sent and a response has been received, or an error
%   has occurred. But with a ContentProvider, MATLAB makes periodic callbacks
%   into the provider to obtain buffers of data to send, during the time send is
%   blocked. In these callbacks your ContentProvider can obtain data from any
%   source such as a file, a MATLAB array, a hardware sensor, a MATLAB function,
%   etc. The provider's job is to convert that data to a byte stream, in the
%   form of uint8 buffers, that can be sent to the web.
%
%   ContentProvider is an abstract class designed for class authors to subclass
%   with their own data generator or converter, or you can use (or subclass) one
%   of MATLAB providers that generate the data for you from various sources,
%   without writing a subclass. These providers have options that give you more
%   flexible control over how data is obtained and converted, compared to the
%   automatic conversions that occur when you insert data directly into a
%   MessageBody:
%
%      FileProvider          send a file
%      StringProvider        send a string
%      JSONProvider          send data as JSON
%      ImageProvider         send an image
%      FormProvider          send form data
%      MultipartProvider     send a multipart message
%      MultipartFormProvider send a multipart form
%      GenericProvider       send from a function
%
%   Even if you do not need to stream data, using one of the above providers can
%   simplify the process of sending certain types of content, as they convert
%   data from an internal form into a uint8 stream. For example FormProvider
%   lets you send form responses to a server, where you can conveniently express
%   the data as an array of QueryParameter, and MultipartFormProvider lets you
%   send multipart form responses, simplifying the creation of responses to
%   multipart forms. To use any ContentProvider you need to understand the type
%   of content that the server expects you to send.
%
%   ContentProvider methods:
%     string        - Return string for debugging
%     show          - Display information about provider
%
%   For subclass authors
%   --------------------
%
%   The simplest possible ContentProvider need only implement a getData method
%   to provide buffers of data as MATLAB requests them. To use your provider,
%   insert it into in the Body property of the RequestMessage. In this example,
%   the third argument to the RequestMessage constructor, a MyProvider object,
%   goes into the Body:
%
%     provider = MyProvider(id);
%     req = matlab.net.http.RequestMessage('put', headers, provider);
%     resp = req.send(uri);
%
%   Here is an example a MyProvider class that reads from a file name
%   passed in as an argument to the constructor and sends it to the web. For
%   good measure we close the file at the end or when this provider is deleted.
%
%   classdef MyProvider < matlab.net.http.io.ContentProvider
%       properties
%           FileID double
%       end
%
%       methods
%           function obj = MyProvider(name)
%               obj.FileID = fopen(name);
%           end
%
%           function [data, stop] = getData(obj, length)
%               [data, len] = fread(obj.FileID, length, '*uint8');
%               stop = len < length;
%               if (stop)
%                   fclose(obj.FileID);
%                   obj.FileID = [];
%               end
%           end
%
%           function delete(obj)
%               if ~isempty(obj.FileID)
%                   fclose(obj.FileID);
%                   obj.FileID = [];
%               end
%           end
%       end
%   end
%
%   MATLAB calls a provider's COMPLETE method when it is forming a new message
%   to send. The purpose is to allow the provider to prepare for a new message
%   and add any required header fields to the message. MATLAB calls a provider's
%   START method when it is time to send the data, but before the first call to
%   GETDATA.
%
%   Restartability and Reusability: 
%     A provider may be restartable and/or reusable. Restartable means that the
%     provider is able to re-send the same message multiple times, with exactly
%     the same data stream each time MATLAB calls START, even if the previous
%     use did not end in a normal completion. This behavior is needed because
%     the server may redirect a message to a different server, which means the
%     data needs to be retransmitted. In that case MATLAB calls START without
%     calling COMPLETE again. MATLAB calls the RESTARTABLE method to determine
%     whether a provider can be restarted. If false, MATLAB throws an exception
%     if it needs to call START on a provider that has already been started, if
%     there was no intervening call to COMPLETE (which happens only on a new
%     message).
%
%     Reusable means that the provider can be reused for a different (or the
%     same) message, each time MATLAB calls its COMPLETE method. MATLAB calls
%     the REUSABLE method to determine whether a provider can be reused. If
%     false, MATLAB throws an exception if it needs to call COMPLETE on a
%     provider that has already been started. If a provider is reusable, the
%     assumption is that the next call to START should succeed, whether or not
%     the provider is restartable.
%
%     ContentProvider returns false for both RESTARTABLE and REUSABLE, so if you
%     are extending this base class directly with a restartable or reusable
%     provider, you should override one or both of these methods to return true.
%     All of the concrete subclasses of ContentProvider in the
%     matlab.net.http.io package are both restartable and reusable, so they
%     return true for these methods. If you are extending one of those
%     subclasses with a provider that is not reusable or restartable, override
%     one or both of those methods to return false.
%
%     The MyProvider class in the example above is neither restartable or
%     reusable, because the provider closes the file at the end of the message.
%     To make it reusable, the fopen call should take place in the COMPLETE
%     method instead of the constructor, thereby restoring the provider's state
%     back to what it was before it was used for a message.
%
%     classdef MyProvider < matlab.net.http.io.ContentProvider
%       properties
%           FileID double
%           Name string
%       end
%
%       methods
%           function obj = MyProvider(name)
%               obj.Name = name;
%           end
%
%           function [data, stop] = getData(obj, length)
%               ...as above...
%           end
%
%           function complete(obj, uri)
%               obj.FileID = fopen(name);
%               obj.complete@matlab.net.http.io.ContentProvider();
%           end
%
%           function tf = reusable(~)
%               tf = true;
%           end
%           
%           function delete(obj)
%               ...as above...
%           end
%       end
%     end
%
%
%     To make the provider restartable, add RESTARTABLE and START methods and
%     issue an fseek in the START method to "rewind" the file:
%
%           function start(obj)
%               obj.start@matlab.net.http.io.ContentProvider();
%               fseek(obj.FileID, 0, -1);
%           end
%
%           function tf = restartable(~)
%               tf = true;
%           end
%
%   When you call COMPLETE or SEND on a RequestMessage that contains a
%   ContentProvider in its body, MATLAB sets the Request property in the
%   provider to the RequestMessage in which the provider was placed and the
%   Header property to the headers in the Request, prior to addition of any
%   automatic fields. It then calls the following methods in the provider, in
%   this order:
%
%     complete             - called on message completion, which usually happens once
%                            per message, when you call RequestMessage.send or
%                            RequestMessage.complete. The provider is expected
%                            to set its Header property to any header fields to
%                            be added to the message specific to the provider.
%                            If MATLAB calls this method a subsequent time, the
%                            provider should assume it is being used for a new
%                            message. Most providers need to implement this
%                            method to add their headers and then, if they are
%                            not a direct subclass of this abstract class, they
%                            should call their superclass complete to invoke any
%                            additional default behavior. MATLAB will not call
%                            complete more than once in a provider, unless its
%                            reusable method returns true. This abstract class
%                            is not reusable by default, but all concrete
%                            providers in the matlab.net.http.io package are
%                            reusable.
%
%
%     preferredBufferSize  - called from RequestMessage.send, sometime after complete, 
%     expectedContentLength  before a call to start. Most providers need not
%                            implement these methods, as the default behavior is
%                            appropriate.  However providers may wish to
%                            override this in order to support the FORCE
%                            argument.
%
%     After return from the above methods, MATLAB sends the header of the
%     RequestMessage to the server. When it is time to send the body, MATLAB
%     calls these:
%
%     start                - called from RequestMessage.send, sometime after the 
%                            above methods, when MATLAB has determined that the
%                            server is ready to receive the body of the request
%                            message. If MATLAB calls this a subsequent time,
%                            without an intervening complete, the provider
%                            should assume it is being asked to re-send the body
%                            of the same message (with the same headers) once
%                            again. MATLAB will not call start more than once
%                            since the last call to complete, unless the
%                            provider's restartable method returns true. This
%                            abstract class is not restartable by default, but
%                            all concrete providers in the matlab.net.http.io
%                            package, are restartable.
%
%      getData             - called multiple times after the call to start,
%                            while RequestMessage.send is blocked, each time
%                            MATLAB determines that the server is ready for a
%                            new buffer of data. The method must return a uint8
%                            vector of data. The provider signals the end of the
%                            data by returning a STOP indicator. All providers
%                            must implement this method.
%
%      After getData returns a STOP indicator, MATLAB ends the request message and
%      awaits a response from the server.
%
%   Delegation: 
%     A ContentProvider that is inserted into a RequestMessage.Body can delegate
%     to one or more other providers to provide all or some of the data for the
%     message. For example, MultipartProvider creates a message with multiple
%     parts, each of which are provided by various other providers specified to
%     the MultipartProvider constructor. In this case, MultipartProvider is the
%     delegator, and the other providers are the delegates, each one being
%     called in turn to provide its own header fields and its portion of the
%     data. 
%
%     A provider delegates to another by calling delegateTo, which sets
%     CurrentDelegate to the delegate and the delegate's MyDelegator to the
%     current provider (i.e., the delegator), and then calls the delegate's
%     complete and start methods. Then the delegator's getData method calls
%     CurrentDelegate.getData to obtain the data, possibly altering it before
%     returning it to MATLAB. Providers generally do not have to check whether
%     or not they are delegates, or who delegated to them.
%
%  ContentProvider properties (set only by MATLAB or delegators):
%    Request               - RequestMessage to be sent
%    MyDelegator           - ContentProvider that delegated to this provider
%
%  ContentProvider properties (set by provider or MATLAB, read by MATLAB)
%    Header                - header fields of the message or part
%    ForceChunked          - true to force chunked transfer coding
%    CurrentDelegate       - current delegate
%
%  ContentProvider methods (protected, optionally implemented by provider; called by MATLAB or subclasses):
%    expectedContentLength - return length of content
%    complete              - complete message
%    preferredBufferSize   - return preferred size of buffers to request
%    start                 - start new transfer
%    restartable           - true if restartable
%    reusable              - true if reusable
%    delegateTo            - delegate to another provider
% 
%  ContentProvider methods (abstract; called by MATLAB, subclasses, delegators)
%    getData               - return next data buffer
%
% See also matlab.net.http.RequestMessage, matlab.net.http.MessageBody,
% FileProvider, StringProvider, JSONProvider, ImageProvider, FormProvider,
% MultipartProvider, MultipartFormProvider, matlab.net.QueryParameter

% Copyright 2016-2017 The MathWorks, Inc.

    properties (Access=private)
        Length uint64         % length returned by expectedContentLength; may be empty
        BytesSent uint64      % bytes sent so far
        Stop logical = false  % true if last call to getData returned both data and stop
        PayloadSize           % used if SavePayload set
        % Started - true if this provider was started
        %   The start method sets this property to true to indicate that this provider
        %   was used to start transmission of data, and the complete method resets this
        %   property to indicate that this provider is ready to start a new message.
        %
        %   The default start and complete methods will throw an exception if this
        %   property is true and the provider is not restartable or reusable,
        %   respectively.
        Started logical = false 
    end
    
    properties (Access={?matlab.net.http.RequestMessage,?matlab.net.http.internal.HTTPConnector})
        SavePayload logical = false % true to log payload
        Payload uint8               % logged payload
        MinLength                   % from actual Content-Length field
        ExpectedLength uint64 % if Length is not [], same as Length; else value of Content-Length in request
    end

    properties (SetAccess={?matlab.net.http.RequestMessage})
        % Request - The request message to be sent
        %   This is a read-only property is of interest only to subclass authors. The
        %   RequestMessage.send and RequestMessage.complete methods set this property to
        %   the RequestMessage in whose Body this provider has been placed, prior to
        %   calling any other methods in this provider, and before adding any additional
        %   header fields or validating the message. The provider may examine this
        %   message to see what was contained in the original request.
        %
        %   Delegates see the same value for this property as the delegator.
        %   Content-Providers should be aware that, if they are delegates, they are not
        %   necessarily providing the entire body of the request message, so they should
        %   not assume that header fields in this Request are pertinent to the data they
        %   are providing. In most cases, delegates should normally ignore header
        %   fields in this request relevant to the data, such as Content-Type.
        %
        %   If a provider wishes to add any header fields to this message, or modify
        %   existing ones, it should do so in its COMPLETE method by adding those fields
        %   to the Header property. The caller of COMPLETE (RequestMessage or a
        %   delegating provider) will determine what do do with those fields.
        %   RequestMessage.send and RequestMessage.complete always copy these fields to
        %   the Header of the RequestMessage. A delegating provider may copy the fields
        %   to its own Header property or insert them into the message (as in the case
        %   of MultipartProvider).  For more information, see Header.
        %
        % See also matlab.net.http.RequestMessage, Header, complete, MultipartProvider
        Request matlab.net.http.RequestMessage
    end
    
    properties
        % Header - Vector of header fields of the message or part
        %   This property is of interest only to subclass authors. MATLAB sets this
        %   property prior to calling the provider's complete method. For normal
        %   non-multipart messages, MATLAB initializes this to the contents of
        %   Request.Header, minus any GenericFields or empty-valued fields. In this
        %   property, the ContentProvider can add header fields that describe the data
        %   to be sent, or add parameters to header fields already in the message. In a
        %   delegate for a MultipartProvider, MATLAB initializes this to any header
        %   fields that the delegating provider intends to insert for the part.
        %   Delegates can modify or change these fields.
        %
        %   Upon return from the provider's complete method, if this not a multipart
        %   message:
        %
        %     MATLAB reads this property and merges its contents into the header of
        %     Request. Fields in this Header with Names that do not already appear in
        %     Request.Header are added to the end of Request.Header. If a field in this
        %     Header has a Name that is the same as one in Request.Header, and both have
        %     nonempty Values:
        %       - If the one in Request.Header is a GenericField ignore the one in Header
        %       - If the one in Request.Header is not a GenericField, replace it with 
        %         the one in Header
        %     If one or both of these has an empty Value, the field is removed from
        %     Request.Header and it will not be added as part of normal message
        %     completion.
        %
        %   If this is a delegate of a MultipartProvider, the entire contents of this
        %   Header is used as the header of the part. Multipart delegates must not
        %   assume that Request.Header contains any fields pertaining to their own
        %   Header. A provider can determine whether it is a multipart delegate by
        %   checking whether MyDelegator is a matlab.net.http.io.MultipartProvider,
        %   though this test is unlikely to be needed.
        %    
        %   MATLAB only reads this property on return from calling the provider's
        %   COMPLETE method. Changes to this array are ignored once MATLAB calls START.
        %
        %   Class authors should be aware that their subclasses may have added fields to
        %   this Header (in their COMPLETE method) prior to calling COMPLETE in their
        %   superclass. It is generally best to preserve such fields and not add new
        %   fields with the same names. However, adding a parameter to a field may be
        %   permissible. For example, a superclass may want to add a charset parameter
        %   to an existing Content-Type field that does not already have one.
        %
        % See also matlab.net.http.HeaderField, complete, start, Request, MyDelegator,
        % matlab.net.http.RequestMessage, MultipartProvider, MultipartFormProvider,
        % matlab.net.http.field.GenericField
        Header  matlab.net.http.HeaderField = matlab.net.http.HeaderField.empty
        
        % ForceChunked - true to force chunked transfer coding
        %   This property is of interest only to subclass authors, and is applicable
        %   only to providers that are not multipart delegates. It is a logical that can
        %   be set by subclasses to control whether contents should be sent using
        %   chunked transfer coding. If false (default), MATLAB decides whether to send
        %   the contents chunked, based on whether it knows the content length at the
        %   time the message is ready to be sent:
        %
        %      - If MATLAB knows content length (which is the case if the
        %        message contains a Content-Length field, or if this provider's
        %        expectedContentLength method returned a number), then MATLAB will
        %        decide whether to send it chunked or not.
        %
        %      - If MATLAB does not know the content length (no Content-Length field in
        %        header and expectedContentLength returned empty), then MATLAB will
        %        always send the messsage chunked.
        %
        %   If this property is true, MATLAB will send the message chunked regardless of
        %   whether it knows the content length, unless the known length is smaller than
        %   the chunk size. If this property is true then the message must not contain
        %   a Content-Length field, because HTTP does not allow a chunked message to
        %   have a Content-Length field. However you may still return a nonzero value in
        %   the expectedContentLength method if you want MATLAB to verify that you are
        %   returning the expected length of data.
        %
        %   When MATLAB chooses to send the message chunked, the size of each chunk will
        %   be equal to the length of data returned by getData.  
        %
        %   MATLAB reads this value after calling the complete method, prior to calling
        %   START. It does not set this field.
        %
        % See also matlab.net.http.RequestMessage, expectedContentLength,
        % MultipartProvider, complete, getData
        ForceChunked logical = false
    end
    
    properties (Access=protected)
        % CurrentDelegate - the ContentProvider to which this provider is delegating
        %   This is set in the calling provider (the delegator) by the delegateTo() method
        %   to indicate the current delegated provider. If there is no current
        %   delegation, the value is empty.
        %
        %   The complete methods sets this property to empty.
        %
        % See also delegateTo, complete, start
        CurrentDelegate matlab.net.http.io.ContentProvider
 
        % MyDelegator - ContentProvider that delegated to this provider
        %   In cases where one ContentProvider delegates responsibility for sending all
        %   or a portion of a message data to another provider, this property identifies
        %   the delegating provider to the delegate. For example, MultipartProvider
        %   delegates parts of the message to other providers, so it inserts a handle
        %   to itself in each delegate. In other cases, this property is empty. This
        %   property is set in the delegate by the delegateTo method.
        %
        % See also CurrentDelegate, delegateTo
        MyDelegator matlab.net.http.io.ContentProvider = matlab.net.http.io.ContentProvider.empty;
    end
    
    methods (Abstract)
        % getData Get the next buffer of data to be sent in the request message
        %   [DATA, STOP] = getData(PROVIDER, LENGTH) returns a buffer of DATA (a uint8
        %   vector), that the provider wishes to send. MATLAB calls this method
        %   multiple times during RequestMessage.send, after calling START, and sends
        %   each buffer of DATA to the server immediately. If the message is chunked
        %   (i.e., expectedContentLength returned empty and there is no Content-Length
        %   field in the message), the size of the chunk will be the length of DATA.
        %
        %   The LENGTH argument is MATLAB's suggested length of data that the provider
        %   should return for optimum interactive behavior. It is based on the value of
        %   preferredBufferSize, if specified, and internal buffer sizes. The provider
        %   may, however, return more or fewer bytes, and if your provider wants to send
        %   chunks of specific sizes, it can ignore LENGTH. MATLAB does not guarantee
        %   that any specific value of LENGTH will be specified, but it will always be a
        %   finite number greater than zero. Note that returning a very large buffer of
        %   DATA may cause MATLAB to block for a considerable time while sending the
        %   data, during which you cannot interrupt the operation using Ctrl+C. This
        %   may not be an issue for non-interactive applications, where larger buffers
        %   are usually more efficient.
        %
        %   The STOP return argument is a logical that the provider must set. If false,
        %   MATLAB will call this method again to get more data when it is ready to send the
        %   next buffer. If true, this indicates that the provider has no more data to
        %   send, beyond what is returned in DATA, and tells MATLAB to end the message.
        %   This is the normal way to end the RequestMessage and prepare MATLAB to
        %   receive a ResponseMessage.
        %
        %   If DATA is empty and STOP is not set, MATLAB will call this method
        %   repeatedly to get more data (after a small delay). The only way to
        %   end the message gracefully is to return STOP=true. However, you can also
        %   throw an exception to abort the message, which will be returned to the
        %   caller of RequestMessage.send.
        %
        %   If the Content-Length header field was included in the message header or
        %   returned by expectedContentLength (i.e., the message is not being sent using
        %   chunked transfer coding), the total number of bytes returned in DATA over
        %   multiple calls, ending with STOP=true, must be equal to that number. If
        %   STOP=true is returned prematurely, or the total amount of DATA returned is
        %   greater than that number, MATLAB throws an exception and closes the
        %   connection.
        %
        % See also start, matlab.net.http.RequestMessage, expectedContentLength, MultipartProvider,
        % preferredBufferSize
        [data, stop] = getData(obj, length)
    end

    methods (Access=protected)
        function length = expectedContentLength(~, varargin)
        % expectedContentLength Implemented by subclasses to return length of content
        %   LENGTH = expectedContentLength(PROVIDER, FORCE) returns the expected content
        %   length in bytes. This method is intended to be overridden by subclasses
        %   that want to report their content length to MATLAB. RequestMessage.send and
        %   RequestMessage.complete call this method and use the return value to set the
        %   Content-Length header field in the RequestMessage. If the message already
        %   has a Content-Length field with a value, and LENGTH is nonempty, its value
        %   must be equal to the value in that Content-Length field. LENGTH may be 0 to
        %   indicate there is no contents, in which case the first call to getData
        %   should return empty DATA and STOP=true.
        %
        %   MATLAB calls this method from RequestMessage.send, RequestMessage.complete
        %   and in the delegate by delegateTo. MATLAB calls this after
        %   ContentProvider.complete and before ContentProvider.start.  If this method
        %   is called prior to a call to complete, the return value may be invalid,
        %   because a provider cannot necessarily determine the length of its converted
        %   data without seeing all the header fields that control the conversion.
        %
        %   You do not need to override this method. By default, this returns [], which
        %   means that the length is determined by some other means:
        %
        %     - If this ContentProvider is not a multipart delegate (see 
        %       MultipartProvider), and the message has a Content-Length field with a
        %       nonempty value (inserted in the original RequestMessage or added to the
        %       Header property by the complete method), then that Content-Length field
        %       is the length of the contents. 
        %     - If there is no Content-Length field (or this provider is a multipart
        %       delegate), the payload (or data in the part) ends when this provider's
        %       getData() sets the STOP return value. In that case, the content length
        %       need not be specified.
        %
        %   If you do not choose to have a Content-Length header field in your message
        %   (i.e., the message is being sent using chunked transfer coding), the only
        %   reason to override this method and return a nonempty value is as a
        %   double-check to insure that that your provider returns the expected length
        %   of data.
        %   
        %   In cases where the length of the data is known (that is, when this method
        %   returns a number or the Content-Length field is nonempty), this provider's
        %   getData() method must return STOP=true after exactly that number of bytes
        %   have been returned. MATLAB will always call getData repeatedly, even if
        %   LENGTH=0, until getData returns STOP=true. In cases where the length is not
        %   known, if this is a top level provider (not a multipart delegate), MATLAB
        %   uses chunked transfer coding to send the contents and the provider is free
        %   to return any length of data, including none, prior to setting STOP=true.
        %
        %   You should return [] if you do not know the length of the data in advance,
        %   or if computing the length of the data would be time-consuming. It is
        %   harmless (and perfectly normal) to allow any message to use chunked transfer
        %   coding, even if you know the length. If this provider is a multipart
        %   delegate, a nonempty return value is only used to force an error in case
        %   getData returns more or fewer bytes, and will not cause a Content-Length
        %   header field to appear in the part. See MultipartProvider for more
        %   information.
        %
        %   The FORCE argument, which is optional, is a logical, which, if true,
        %   requires that you return the length of the data, computing it if necessary,
        %   even if you would otherwise return [], unless computing the length is
        %   impossible. If returning this number requires a lengthy computation or
        %   generation of all the data in the message, then you should cache the data so
        %   that you do not have to recompute it in subsequent getData calls. The FORCE
        %   argument is provided for use by subclasses who must know the length of the
        %   data in advance. MATLAB never sets this option when calling this method, but
        %   providers in the matlab.net.http.io package support it. If you know that
        %   your provider will never be used as a subclass that might set this option,
        %   you can ignore the FORCE argument.
        %
        %   Callers of this method who get [] in response to setting FORCE to true can
        %   either consider it an error, or behave in a way that is compatible with
        %   content of unknown length.
        %
        %   Specifying FORCE can negate the benefit of streaming (sending data as it is
        %   being generated) if it requires all the data to be generated to compute
        %   LENGTH, so this option is best used for special cases, e.g. debugging, or
        %   when the length of data is known to be small. 
        %
        %   An example of the use of FORCE is a hypothetical CompressProvider that
        %   optionally compresses the output of any other provider, but only if that
        %   output is greater than a certain length (because compression is inefficient
        %   for short messages). To determine the length, the CompressProvider needs to
        %   invoke the other provider's expectedContentLength with FORCE set to true. If
        %   that other provider is a streaming JSONProvider, expectedContentLength normally
        %   returns [], because determining the length of a JSON string requires
        %   processing all of the input data. With FORCE set to true, the
        %   JSONProvider's expectedContentLength method processes all of the data (perhaps
        %   caching the output string internally for later use by its putData method),
        %   and returns that string's length.
        %
        % See also matlab.net.http.RequestMessage, Request, Header, complete, getData,
        % MultipartProvider, JSONProvider
            length = [];
        end
        
        function complete(obj, ~)
        % COMPLETE Complete the header
        %   COMPLETE(PROVIDER, URI) augments the header of the message with header
        %   fields desired by this provider. URI is a URI object. The
        %   RequestMessage.send and RequestMessage.complete methods call this method
        %   prior to validating the header or adding any default fields, and prior to
        %   calling other methods in this class except for expectedContentLength.
        %
        %   This is where subclasses can add any fields to Header that depend on the
        %   content, such as Content-Type. See the description of the Header property
        %   for more information.
        %
        %   The RequestMessage methods do not call this method if the message has
        %   already been completed (that is, if RequestMessage.Complete is true).
        %   However a subsequent change to the message after completion will reset the
        %   RequestMessage.Completed property, allowing those methods to invoke this
        %   method again. Therefore providers should be prepared for more than one
        %   call to COMPLETE prior to a call to START. Once START has called, MATLAB
        %   will not reinvoke COMPLETE in this provider unless REUSABLE returns true to
        %   indicate that this provider can be reused for another message.
        %   
        %   A ContentProvider that extends another ContentProvider should first call its
        %   superclass COMPLETE to add header fields to Header that the superclass
        %   needs, and then, on return, modify those fields if desired.
        %
        %   A simplified coding pattern for a ContentProvider that extends a reusable
        %   SuperclassProvider and intends to add the HeaderField myField is this:
        %
        %       function COMPLETE(obj, uri)
        %           COMPLETE@SuperclassProvider(obj, uri);
        %           field = obj.Header.getFields('My-Field');
        %           if isempty(field)
        %               myField = HeaderField('My-Field', value);
        %               obj.Header = obj.Header.addFields(myField);
        %           end
        %
        %   The default behavior of this method does nothing, but throws an exception if
        %   this provider has been started and is not reusable. Providers that override
        %   this method should always invoke their superclass.
        %
        %   If this provider is not a multipart delegate, and you want to include a
        %   Content-Length field in the message (thereby avoiding chunked transfer
        %   coding), you should return a nonempty value in expectedContentLength or
        %   implement this method to insert a Content-Length field in Header.
        %
        %   This method is not invoked on messages whose Completed property is true,
        %   which generally means that this method is invoked only once per message,
        %   even if this message is resent multiple times. Implementations of this
        %   method should therefore perform any initialization that needs to be done
        %   only once per message. Costly initialization that does not need to be done
        %   until the data is ready to be sent should be performed in the START method.
        %
        % See also matlab.net.http.RequestMessage, Request, Header, reusable
        % expectedContentLength, start
            obj.throwIfNotReusable();
            obj.Started = false;
            obj.ExpectedLength = []; % expectedContentLength() to be called later
            obj.CurrentDelegate = matlab.net.http.io.ContentProvider.empty;
         end
        
        function size = preferredBufferSize(~)
        % preferredBufferSize Get preferred buffer size
        %   SIZE = preferredBufferSize(PROVIDER) returns this provider's preferred size of
        %   data buffers that MATLAB should specify in the LENGTH parameter to getData.
        %   By default this returns [], which indicates that this provider does not care
        %   what size of buffers are requested and MATLAB should choose a size. Since
        %   getData can always return fewer or more bytes than this, this value is
        %   basically an optimization to minimize the number of getData calls and amount
        %   of data copying that may take place.
        %
        % See also getData, expectedContentLength
            size = [];
        end
        
        function start(obj)
        % START Start a new transfer
        %   START(PROVIDER) is called each time MATLAB is about to start transfer of a
        %   data stream by calling getData one or more times. Each time this is called,
        %   the provider is expected to reset so that the next call to getData goes back
        %   to the beginning of the data stream. 
        %
        %   A call to this method indicates that a connection to the server has been
        %   established and transfer of data is about to start. A subsequent call to
        %   START (without an intervening call to COMPLETE) might indicate that the
        %   server has requested a redirect to a different server, or requires another
        %   try with authentication credentials, and this could occur prior to, during
        %   or after transmission of the data stream.
        %
        %   If your provider is restartable, reset your provider so that the next call
        %   to getData will return to the beginning of the data stream, and insure that
        %   RESTARTABLE returns true.
        %
        %   If your provider is not restartable for the same message, but can be reused
        %   for a new message, insure RESTARTABLE returns false.
        %
        %   Subclasses that override this method should always call their superclass
        %   method first. The default behavior of this method throws an exception if
        %   the provider was already started and is not restartable.
        %
        %   This method is the best place to implement any costly initialization that is
        %   not needed until the server is ready to receive data, as opposed to the
        %   complete method which must do initialization necessary to create the message
        %   header. If the server cannot be contacted or rejects the message, MATLAB
        %   will not call this method.
        %
        % See also getData, complete, restartable, reusable
        
            obj.resetPrivate();
            obj.Started = true;
        end
        
        function tf = restartable(~)
        % RESTARTABLE Indicate whether provider is restartable
        %   TF = RESTARTABLE(PROVIDER) returns true if the provider can restart
        %   transmission of the same data, by accepting a subsequent call to START
        %   without an intervening call to COMPLETE. See the class description of
        %   ContentProvider for more information on restartability. Default returns
        %   false, but most concrete subclasses return true.
        %
        % See also start, complete, reusable, ContentProvider
            tf = false;
        end
        
        function tf = reusable(~)
        % REUSABLE Indicate whether provider is reusable
        %   TF = REUSABLE(PROVIDER) returns true if the provider can be reused for a new
        %   message, by accepting a subsequent call to COMPLETE. See the class
        %   description of ContentProvider for more information on reusability. Default
        %   returns false, but most concrete subclasses return true.
        %
        % See also start, complete, restartable, ContentProvider
            tf = false;
        end
        
        function [getDataFcn, length] = delegateTo(obj, delegate, uri, force)
        % delegateTo Delegate to another provider
        %   [getDataFcn, LENGTH] = delegateTo(PROVIDER, DELEGATE, URI, FORCE) sets up a DELEGATE
        %   ContentProvider to provide all or part of the subsequent data in a
        %   RequestMessage. This method initializes properties in the delegate using
        %   properties of this object and supplied parameters, as if a new message was
        %   about to be transmitted using that delegate, and invokes the COMPLETE,
        %   expectedContentLength, and START methods in the delegate. It returns a
        %   handle to a function, getDataFcn, that you should invoke to obtain
        %   data from the delegate:
        %       [data, stop] = getDataFcn(length)
        %   where the arguments are as described for getData. You can pass in any value
        %   of length you want, but normally you would make this call in your getData
        %   method, and therefore pass in the same value of length that was passed into
        %   your method. 
        %
        %   The URI is the URI of the request as initially provided to the caller's
        %   COMPLETE method.
        %
        %   The optional FORCE argument is a logical that this method should pass along
        %   to the expectedContentLength method. If missing, false is used. LENGTH is
        %   the value returned by expectedContentLength.
        %
        %   If you want to delegate to a provider that will provide the entire contents
        %   of a message, call delegateTo in your start method. If you are using the
        %   delegate to obtain just part of the message content, call delegateTo at the
        %   appropriate time in your putData method.
        %
        %   To obtain data from the delegate, always use the returned getDataFcn. Do
        %   not call the delegate's getData directly because the delegate may choose to
        %   provide its data through some other means.
        %
        % See also complete, start, expectedContentLength, getData
            delegate.Request = obj.Request;
            delegate.Header = matlab.net.http.HeaderField.empty;
            delegate.MyDelegator = obj;
            obj.CurrentDelegate = delegate;
            % Normally complete() calls this, but do it here in case delegate overrides
            % complete() without calling its superclass.
            delegate.throwIfNotReusable();
            delegate.completeInternal(uri);
            % this is nonempty if delegate added a Content-Length field
            clfLen = delegate.ExpectedLength;
            if nargin < 4
                force = false;
            end
            % we need to reset the delegate before calling other methods.
            delegate.resetPrivate();
            length = delegate.expectedContentLengthInternal(force);
            if ~isempty(clfLen) 
                if ~isempty(length) 
                    if clfLen ~= length
                        % if both expectedContentLength and Content-Length are nonempty,
                        % their values must be the same
                        error(message('MATLAB:http:InconsistentHeaderValue', 'Content-Length', ...
                            string(clfLen), string(length)));
                    end
                else
                    % Content-Length specified but expectedContentLength empty; use
                    % Content-Length
                    delegate.ExpectedLength = clfLen;
                    length = clfLen;
                end
            end
            delegate.startInternal();
            getDataFcn = @(len)delegate.getDataInternal(len);
        end
    end
    
    methods
        function set.ForceChunked(obj, value)
            if ~isempty(value)
                validateattributes(value, {'logical'}, {'scalar'}, mfilename, 'ForceChunked');
                obj.ForceChunked = value;
            else
                obj.ForceChunked = false;
            end
        end
        
        function str = string(obj)
        % STRING Return information about provider as a string
        %   STR = STRING(PROVIDER) returns information about the provider in the form of
        %   a string. 
        %
        %   This method is intended for debugging. It also invoked by calling in STRING
        %   in MessageBody or RequestMessage that contains this provider. In this
        %   abstract class, it simply returns the class of the provider. Subclasses may
        %   override this to return the provider's data, if there is any, or other
        %   information about the provider.
        %
        % See also matlab.net.http.MessageBody, matlab.net.http.RequestMessage
            str = string(class(obj));
        end
        
        function str = show(obj, maxLength)
        % SHOW Display information about provider
        %   SHOW(PROVIDER) displays information about the provider and possibly its
        %   data.
        %   SHOW(PROVIDER,MAXLENGTH) displays up to MAXLENGTH characters of data. If the
        %   data is longer than that, displays a message indicating the total length in
        %   characters. 
        %   STR = SHOW(___) returns that information as a string.
        % 
        %   This method is intended for debugging. It is also invoked when calling 
        %   SHOW in a RequestMessage whose Body contains this provider. In this abstract
        %   class, this method returns the value of the STRING method, but limiting the
        %   output to MAXLENGTH characters.
        %
        % See also string
        
            % This may be a callout to an overridden string method, so try real hard to
            % convert it to a string if it isn't
            res = obj.string();
            if ~isstring(res)
                try
                    res = string(res);
                catch
                end
            end
            validateattributes(res, {'string'}, {'scalartext'}, class(obj), [class(obj) '.string']);
            if nargout > 0
                if nargin > 1 && maxLength < strlength(res)
                    str = extractBefore(res,maxLength+1);
                else
                    str = res;
                end
            else
                if nargin == 1
                    fprintf("%s\n", res);
                else
                    fprintf("%.*s\n", maxLength, res);
                end
            end
            if nargin > 1 && strlength(res) > maxLength
                lmsg = message('MATLAB:http:TotalCharsOfData', strlength(res));
                lmsg = lmsg.getString();
                if nargout > 0
                    str = str + newline + newline + lmsg + newline;
                else
                    fprintf("\n%s\n",lmsg);
                end
            end
        end
    end
    
    methods (Access=private)
       function resetPrivate(obj)
       % Reset this provider to restart. This only helps if the provider is
       % restartable. This clears private properties except those which are computed
       % by other methods that are always called on a start or restart.
            obj.throwIfNotRestartable();
            obj.Stop = false;
            obj.BytesSent = 0;
       end
        
       function throwIfNotRestartable(obj)
       % Throws an error if this provider was ever started, and is not startable. This
       % is called by start() and startInternal() to make sure the delegate can be
       % restarted.
            if ~obj.restartable() && obj.Started
                throw(MException(message('MATLAB:http:CannotRestart',class(obj))));
            end
       end
       
       function throwIfNotReusable(obj)
       % Throws an error if this provider was ever started, and is not reusable. This
       % is called by complete() and delegateTo() to make sure the delegate can be
       % reused.
            if ~obj.reusable() && obj.Started
                throw(MException(message('MATLAB:http:CannotReuse',class(obj))));
            end
       end
    end        
    
    methods (Access={?matlab.net.http.RequestMessage, ?matlab.net.http.internal.HTTPConnector, ?matlab.net.http.io.MultipartProvider})
        function startInternal(obj)
        % Internal function called from infrastructure and C++
        % Delegates to start() with error checking. Each call resets the BytesSent
        % field in case the provider is restartable.

            % Normally the start() method calls this, but a subclass's overridden start()
            % might have failed to call its superclass, so do it here.
            obj.resetPrivate();
            obj.start();
            if obj.SavePayload
                if isempty(obj.ExpectedLength)
                    len = 128e3;
                else
                    len = obj.ExpectedLength;
                end
                obj.Payload = zeros(len,1);
                obj.PayloadSize = 0;
            end
        end
        
        function [data, stop] = getDataInternal(obj, len)
        % Internal function called from infrastructure and C++
        % Delegates to getData() with error checking  
            function truncatePayload
            % On any fatal exit or normal end of data, truncate the Payload property to the
            % current size
                if obj.SavePayload
                    obj.Payload(obj.PayloadSize+1:end) = [];
                end
            end        
            if obj.Stop
                % last call told us to stop
                obj.Stop = false;
                data = [];
                truncatePayload()
                return;
            end
            try
                [data, stop] = obj.getData(len);
                if ~islogical(stop) || ~isscalar(stop)
                    validateattributes(stop, {'logical'}, {'scalar'}, class(obj), 'STOP');
                end
                while isempty(data) && ~stop
                    pause(.01);
                    [data, stop] = obj.getData(len);
                end
                if ~isempty(data) && ~isa(data,'uint8')
                    validateattributes(data, {'uint8'}, {'vector'}, class(obj), 'DATA');
                end
                data = reshape(data, [], 1); % make vector
                if ~isempty(data)
                    obj.BytesSent = obj.BytesSent + length(data);
                end
                if ~isempty(obj.ExpectedLength)
                    % if ExpectedLength is empty, then the provider can send any number of bytes it
                    % wants. Otherwise, it must send exactly ExpectedLength bytes, returning []
                    % to indicate EOF when done.
                    if obj.BytesSent > obj.ExpectedLength
                        % We expected the provider to return EOF after ExpectedLength. The server
                        % will silently ignore these bytes, so error out to indicate a problem.
                        error(message('MATLAB:http:TooManyBytesSentByProvider', class(obj), obj.BytesSent, obj.ExpectedLength));
                    elseif stop && obj.BytesSent ~= obj.ExpectedLength
                            % Provider is specifying EOF before ExpectedLength. If we don't abort here,
                            % attempt to read the response message will time out, because the server is
                            % expecting more data first.
                            error(message('MATLAB:http:TooFewBytesSentByProvider', class(obj), obj.BytesSent, obj.ExpectedLength));
                    end
                end
            catch e
                truncatePayload()
                rethrow(e);
            end
            if stop && isempty(obj.MyDelegator) && ...
               ~isempty(obj.MinLength) && obj.MinLength > obj.BytesSent
                % for top level provider, data sent must match Content-Length, if any
                % Content-Length is greater than bytes sent. This can only happen if
                % Content-Length was GenericField
                warning(message('MATLAB:http:TooFewBytesInProviderData', ...
                    class(obj), obj.BytesSent, obj.MinLength));
            end
            if ~isempty(data)
                if obj.SavePayload
                    neededLength = obj.PayloadSize + length(data);
                    if neededLength > length(obj.Payload)
                        newPayload = zeros(max([obj.PayloadSize*2 neededLength]), 1);
                        newPayload(1:obj.PayloadSize) = obj.Payload(1:obj.PayloadSize);
                        obj.Payload = newPayload;
                    end
                    obj.Payload(obj.PayloadSize+1:neededLength) = data;
                    obj.PayloadSize = neededLength;
                end
                % since we have data this time, save the stop bit for the next call
                obj.Stop = stop;
            elseif stop
                % we have no data, so if stop is set, finish payload
                truncatePayload()
            end
        end
        
        function size = preferredBufferSizeInternal(obj)
        % Internal function called from C++
        % Delegates to preferredBufferSize with error checking
        % Converts [] return value to 0
            size = obj.preferredBufferSize();
            if isempty(size)
                size = 0;
            else
                if ~isnumeric(size) || ~isscalar(size) || ~isreal(size) || size <= 0
                    msg = message('MATLAB:http:BadReturnValueFromMethod', 'preferredBufferSize');
                    validateattributes(size, {'numeric'}, {'>', 0, 'integer', 'scalar'}, mfilename, msg.getString);
                end
            end
            size = uint64(size);
        end
        
        function length = expectedContentLengthInternal(obj, force)
        % Internal function called from C++
        % Delegates to expectedContentLength with error checking
            length = obj.expectedContentLength(force);
            obj.Length = length;
            if ~isempty(length)
                % If not empty, save the length in ExpectedLength. If empty, the
                % completeHeaderInternal function should have copied the Content-Length into the
                % ExpectedLength (if there was none, RequestMessage will complain).
                if ~isscalar(length) || isinf(length) || ~isnumeric(length) || length < 0
                    msg = message('MATLAB:http:BadReturnValueFromMethod', 'expectedContentLength');
                    validateattributes(length, {'numeric'}, {'>=' 0, 'integer', 'scalar'}, mfilename, msg.getString);
                end
                % Copy the returned Length into the ExpectedLength. Any discrepency between this
                % and the Content-Length in the header will be checked by our caller
                % (RequestMessage or MyDelegator)
                obj.ExpectedLength = length;
            end
        end
        
        function completeInternal(obj, uri)
            % Normally complete() calls this, but do it here in case the subclass overrides
            % complete() and fails to call its superclass.
            obj.throwIfNotReusable();
            obj.complete(uri);
            obj.Started = false;
            if ~isscalar(obj.Request)
                msg = message('MATLAB:http:BadReturnValueFromMethod', 'completeMessage');
                validateattributes(req, {'matlab.net.http.RequestMessage'}, {'scalar'}, mfilename, msg.getString);
            end
            % Get the expected length from the Content-Length field, which may have been set
            % in header by complete(), or is in the Request. If neither, set it to empty
            % for now. A subsequent call to expectedContentLength may override this.
            clf = obj.Header.getValidField('Content-Length');
            if ~isempty(clf)
                obj.ExpectedLength = clf(1).getNumber();
            else 
                obj.ExpectedLength = [];
            end
            obj.Stop = false;
            obj.BytesSent = 0;
        end
    end
        
    methods (Static, Sealed, Access = protected)
        function default_object = getDefaultScalarElement
            default_object = matlab.net.http.io.internal.DefaultProvider;
        end
    end
end