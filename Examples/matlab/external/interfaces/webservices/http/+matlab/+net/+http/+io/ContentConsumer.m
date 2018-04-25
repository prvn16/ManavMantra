classdef (Abstract) ContentConsumer < handle & matlab.mixin.Heterogeneous
% ContentConsumer Consumer for HTTP payloads
%   This is an abstract class that implements the basic functionality of a
%   ContentConsumer. A ContentConsumer is an object that converts data being
%   received in an HTTP ResponseMessage to a MATLAB type or processes the data
%   in some manner. The consumer gets called repeatedly during receipt of an
%   HTTP response message to process buffers of the payload as it is being
%   received. This permits receipt of streamed data within a message, allowing
%   you to act on or display data in a timely manner while it is being received,
%   or to abort transfer prior to receiving the entire message. It also permits
%   some degree of overlap between network I/O and CPU time that can improve
%   latency when time to process the data is comparable to the speed of the
%   network.
%
%   This is an abstract class that you cannot instantiate directly. MATLAB
%   provides a number of ContentConsumers that you can use to process or convert
%   data:
%
%        FileConsumer        save a file
%        StringConsumer      save a string
%        JSONConsumer        save a JSON string as MATLAB data
%        ImageConsumer       save an image
%        MultipartConsumer   save parts of a multipart message
%        BinaryConsumer      save binary data
%        GenericConsumer     save multiple types of data
%
%   To get the full benefit of streaming you will want to write you own subclass
%   of this class or one of the provided subclasses to intercept the data as it
%   is being received, perhaps disposing of it in some special manner or sending
%   it elsewhere.
%
%   You use a ContentConsumer by specifying it in the call to
%   RequestMessage.send. This consumer is a "top level" consumer to which
%   MATLAB passes the entire payload as it is being received, a buffer at a
%   time:
%
%     req = RequestMesage;
%     resp = req.send(url, [], MyConsumer);
%
%   A consumer may also be a "delegate" that is invoked by some other
%   consumer to handle all or part of the data in a message:
%
%     mp = MultipartConsumer('image/*', ImageConsumer, 'text/*', StringConsumer);
%     resp = req.send(url, [], mp);
%
%   In the above example mp is the top level consumer that receives the entire
%   payload of a multipart message, while ImageConsumer and StringConsumer are
%   delegate consumers that get only those parts of the payload that are images
%   or text, respectively. GenericConsumer also uses delegates.
%   ContentConsumers normally do not care whether they are top level consumers
%   or delegates: any consumer in the matlab.net.http.io package can work as a
%   delegate.
%
%   For subclass authors
%   --------------------
%
%   If your subclass directly extends ContentConsumer (as opposed to one of the
%   provide subclasses), it must implement the start method and should implement
%   the putData method to process buffers of data as they are being received.
%   This is a handle class, so methods in this class may modify the object.
%   Objects of this class may be serially reused for subsequent messages, but
%   they may not be used for more than one message at a time.
%
%   MATLAB invokes the top level consumer's initialize method after receiving the
%   header of a ResponseMessage, prior to reading the payload. If initialize
%   returns true, this indicates that the consumer is willing to process the
%   payload. If false, processing continues as if no consumer had been
%   specified.
%   
%   MATLAB gives the top level consumer an opportunity to process the payloads
%   of all response messages received during an exchange, regardless of status,
%   including redirect messages and authentication challenges. The default
%   initialize() method returns true only if Response.Status is StatusCode.OK,
%   which excludes redirect and authentication challenges. Messages not accepted
%   by a consumer are silently processed in a default manner as if there was no
%   consumer.
%
%   ContentConsumer properties (set by MATLAB or subclasses):
%     ContentLength      - *Expected length of current payload
%     ContentType        - *MediaType of current payload
%     AllocationLength   -  anticipated size of buffers of data
%     URI                -  URI to which the request was addressed
%     Request            -  copy of RequestMessage that was sent
%     Response           -  ResponseMessage (initially headers only) that was received
%     Header             - *Current headers
%
%   ContentConsumer properties (protected, set by MATLAB or subclasses):
%     CurrentLength      -  Current length of data stored in Response
%     CurrentDelegate    -  The current delegate, set in delegator
%     MyDelegator        - *ContentConsumer that delegated to this consumer
%     AppendFcn          - *Function that putData calls to append data
%
%   For a top level consumer, RequestMessage.send initializes all the above
%   properties based on the request and response header. If the top level
%   consumer delegates to another consumer, it sets CurrentDelegate to the
%   delegated consumer and copies most of its properties to the delegate, except
%   that properties indicated by * may have different values from those in the
%   delegator. For example, in a multipart message, the MultipartConsumer sets
%   Header, ContentLength and ContentType in the delegate to values from the
%   header of the message part, not the header of the Response.
%   
%   ContentConsumer methods:
%     ContentConsumer    - constructor
%
%   ContentConsumer methods (generally called by MATLAB, subclasses, delegators):
%     initialize         - (protected) initialize for new message
%     start              - (abstract, protected) start of data transfer
%     putData            - process next buffer of data
%     delegateTo         - (protected) delegate to another consumer
%
%   In a typical data exchange, MATLAB operates on the consumer in this order,
%   after receiving a ResponseMessage header and determining that a payload may
%   follow:
%
%     set consumer properties: Header, ContentLength, URI, ContentType, Response
%     if consumer.initialize() 
%         if payload is nonempty
%             consumer.start()
%             while server sends more data:
%                 get buffer of data from server
%                 [len, stop] = consumer.putData(data);
%                 if stop
%                    break;
%                 end
%             end
%             consumer.putData(uint8.empty);   % end of data
%         end
%     end
%
% See also matlab.net.http.RequestMessage, matlab.net.http.ResponseMessage,
% MultipartConsumer, GenericConsumer, StringConsumer, ImageConsumer,
% FileConsumer, JSONConsumer, BinaryConsumer

% Copyright 2016-2017 The MathWorks, Inc.

    properties 
        % ContentLength - Expected length of payload
        %   This is the anticipated length of the payload. it is normally the value
        %   of the ContentLengthField in Header. If empty, the length is not known:
        %   the payload ends when putData(uint8.empty) is called.
        %
        %   MATLAB sets this property prior to the call to initialize for the
        %   convenience of subclasses who might benefit from knowing the length of
        %   data. It is normally the same as the value of the ContentLengthField in
        %   Header.
        %
        % See also matlab.net.http.field.ContentLengthField, Header, initialize
        ContentLength    uint64

        % ContentType - MediaType of payload
        %   This is the MediaType of the payload. It is normally the value of the
        %   ContentTypeField in Header. If empty, the ContentTypeField was empty or
        %   nonexistent.
        %
        %   MATLAB sets this property prior to calling initialize, for the convenience
        %   of subclasses who want to examine the MediaType. Subclasses can set this
        %   property if they determine, from the data, that it is of a different
        %   MediaType. At the end of the transfer, MATLAB copies this value into
        %   Response.Body.ContentType. 
        %
        % See also matlab.net.http.field.ContentTypeField, matlab.net.http.MediaType,
        % Header, initialize, Response
        ContentType     matlab.net.http.MediaType

        % AllocationLength - Suggested buffer size
        %   MATLAB sets this to the anticipated size of buffers of data that will be
        %   delivered to putData, though the actual size may be smaller or larger.
        %   This is for performance, in case the consumer needs to preallocate space
        %   to dispose of the data.
        %   
        %   MATLAB sets this property for the convenience of subclasses, prior to the
        %   call to start.
        %
        % See also putData, start
        AllocationLength uint64 

        % URI - Destination of the request being processed
        %   This is the original destination URI as determined by RequestMessage.send.
        %   It is not the URI of a proxy or the final URI after redirections.
        %
        %   MATLAB sets this property for the convenience of subclasses prior to
        %   the call to initialize.
        %
        % See also matlab.net.http.RequestMessage, matlab.net.URI, initialize
        URI              matlab.net.URI

        % Request - Completed RequestMessage that was sent
        %   This is the final RequestMessage after all redirections, the same as the
        %   COMPLETEDREQUEST return value from RequestMessage.send.
        %
        %   MATLAB sets this property for the convenience of subclasses prior to the
        %   call to initialize.
        %
        % See also matlab.net.http.RequestMessage, initialize
        Request          matlab.net.http.RequestMessage
        
        % Header - header of the payload currently being processed
        %   Consumers should use this header to determine how to process the payload
        %   that is being sent to them. For the top level consumer, this is the same
        %   as Response.Header, but it could be different for a delegate. For
        %   example, in a multipart message being processed by a MultipartConsumer, it
        %   is the header of the part that this delegate is processing. The delegate
        %   can still examine Response.Header for headers of the original message.
        %
        %   MATLAB sets this property for the convenience of subclasses prior to the
        %   call to initialize.
        %
        % See also Response, matlab.net.http.HeaderField, MultipartConsumer,
        % initialize
        Header           matlab.net.http.HeaderField
    end
    
    properties (Dependent)
        % Response - ResponseMessage being processed
        %   MATLAB sets this, prior to the call to initialize, to the ResponseMessage
        %   after headers have been received but prior to receiving any payload. At the
        %   start of response message processing, or, for multipart messages, the start
        %   of a part, the ResponseMesssage's Body is initially a MessageBody with empty
        %   Data and Payload. To store received data, Consumers may modify the Response
        %   and MessageBody.Data in any way during data transfer. In most cases
        %   consumers that process and then store data will set Response.Body.Data to
        %   their processed payload, though this is not required. At the completion of
        %   the transfer, MATLAB returns this Response to the caller of
        %   RequestMessage.send. Consumers should not modify other properties
        %   of Response, such as the Header or StatusLine, as those changes will be
        %   returned to the caller.
        %
        %   Response.Body.Payload is empty during the transfer and consumers should not
        %   attempt to modify it. If HTTPOptions.SavePayload is set, then MATLAB sets
        %   Payload to the received payload at the end of the transfer of the message or
        %   the part (after the call to putData(uint8.empty)) or when an exception occurs.
        %
        %   If an exception occurred in the consumer during message processing, MATLAB
        %   throws an HTTPException whose History contains this Response.
        %
        %   If the consumer is a delegate that is processing part of a multipart
        %   message, Response.Header contains the header of the whole message, and the
        %   Payload and Data properties of Response.Body are cleared prior to invoking
        %   the ContentConsumer for each part. At the conclusion of each part, a new
        %   ResponseMessage is added to the end of the array of ResponseMessages in the
        %   original response's Body.Data containing the Header from this object and the
        %   Body from this property. The next delegate will see a fresh Response
        %   with an empty MessageBody, not the previous delegate's MessageBody.
        %
        % See also Header, matlab.net.http.ResponseMessage,
        % matlab.net.http.RequestMessage, matlab.net.http.MessageBody,
        % matlab.net.http.HTTPException, matlab.net.http.HTTPOptions
        Response         matlab.net.http.ResponseMessage
    end
    
    properties (Hidden, SetAccess=private)
        PayloadLength    double  % Cumulative length of raw payload sent to putData
        InUse            logical = false % true between initalize() and putData(empty)
    end
    
    properties (SetAccess=private, GetAccess=?matlab.net.http.RequestMessage)
        Exception MException % exception to throw when current transfer is done
    end
    
    properties (Access=private)
        ResponseInt matlab.net.http.ResponseMessage
    end
    
    properties (Hidden, Access=protected)
        SavePayload = false % undocumented; value of HTTPOptions.SavePayload
    end
    
    properties (Hidden, Dependent, Access=?matlab.net.http.RequestMessage)
        OptionsSavePayload % undocumented; value of HTTPOptions.SavePayload
    end
    
    methods
        function set.OptionsSavePayload(obj, value)
            obj.SavePayload = value;
        end
        function value = get.OptionsSavePayload(obj)
            value = obj.SavePayload;
        end
    end
            
    
    properties (Access=protected)
        % CurrentLength - if nonempty, length of data currently in Response.Body.Data
        %   This property is used when Response.Body.Data has been preallocated to a
        %   size larger than the actual amount of data currently stored, to indicate the
        %   length of that stored data. If this property is empty, it means that all of
        %   Response.Body.Data contains the stored data or that a ContentConsumer
        %   subclass is disposing of the data in some way other than storing it in
        %   Response.Body.Data.
        %   
        %   This property is used and set by the putData in this base class when
        %   AppendFcn is empty. It is for the benefit of subclasses that call putData
        %   and want to examine already-stored data, and/or any implementations of
        %   AppendFcn that maintain results in Response.Body.Data. 
        %
        %   Subclasses that use putData may also modify this property to reset the
        %   position in the buffer where the data is stored. For example, when the
        %   default AppendFcn function is used, a subclass that processes all of
        %   Response.Body.Data on each call to putData may no longer have a use for the
        %   original data, so it can reset CurrentLength to 1 so that the next putData
        %   call overwrites the buffer with new data. There is no need to clear
        %   elements in the buffer past the end of the new data.
        %
        %   Subclasses that do not call putData may use this property to keep track of
        %   their own data, or may leave it unset (empty). MATLAB does not place any
        %   constraints on the value that may be set here and does not use it for any
        %   purpose other than to determine where the default AppendFcn should store the
        %   next buffer of data, and where to truncate the data at the end of the
        %   message. Set this property to empty prior to the final call to
        %   putData(uint8.empty) to prevent truncation of the data.
        %
        %   MATLAB sets this property to empty prior to each call to initialize.
        %
        % See also Response, putData, initialize, AppendFcn
        CurrentLength uint64 = uint64.empty
        
        % CurrentDelegate - the ContentConsumer to which this consumer is delegating
        %   This is set in the calling consumer (the delegator) by the delegateTo() method
        %   to indicate the current delegated consumer. If there is no current
        %   delegation, the value is [].
        %
        %   This property is set to [] prior to each call to initialize.
        %
        % See also delegateTo, initialize
        CurrentDelegate % matlab.net.http.io.ContentConsumer

        % AppendFcn - function called by putData to append additional data
        %   The putData method in this class calls this to append new data it receives
        %   in its DATA argument to existing data in the response message. The function
        %   must have the signature:
        %
        %        AppendFcn(CONSUMER, NEWDATA)
        %
        %   where NEWDATA is the data to be appended to the array at
        %   CONSUMER.Response.Body.Data. It is the responsibility of this method to
        %   update CONSUMER.CurrentLength to reflect the new length of Data. If NEWDATA
        %   is empty, which indicates the end of the stream, the function should update
        %   Response.Body.Data to its final value.
        %
        %   The default behavior, if this property is empty, uses an internal function
        %   that treats Data as an array of arbitrary values supporting horzcat. It
        %   efficiently adds data by preallocating space, maintaining CurrentLength to
        %   be the actual length of data stored. At the end of the message it truncates
        %   Response.Body.Data to CurrentLength. None of this happens if AppendFcn is
        %   set.
        %
        %   Subclasses may want to change this property if the append process is not a
        %   simple horzcat. For example, when StringConsumer is building a scalar
        %   string, it adds to the string using the plus function instead of horzcat.
        %
        %   The AppendFcn is not required to necessarily add NEWDATA to the end of an
        %   array. It can choose to process the NEWDATA in any way it desires, for
        %   example by storing an object in Response.Body.Data and invoking methods in
        %   that object. Also, a consumer might periodically replace the stored data
        %   with a different form. For example, during receipt of a message,
        %   JSONConsumer may accumulate a string, but at the end of the string, or when
        %   it has a complete JSON object, it may convert that data to a structure
        %   array. The value of CurrentLength can be any measure of progress and need
        %   not necessarily be the length of any array.
        %
        %   Subclasses that do not invoke ContentConsumer.putData to append data, or
        %   which are satisfied with simple horzcat behavior to appending data, can
        %   ignore this property.
        % 
        % See also putData, horzcat, Response, CurrentLength,
        % matlab.net.http.ResponseMessage, StringConsumer
        AppendFcn function_handle
        
        % MyDelegator - The ContentConsumer that delegated to this consumer
        %   If this consumer is a delegate that was invoked by another consumer, such as
        %   a GenericConsumer or MultipartConsumer, this is the calling consumer. It is
        %   empty in a top level consumer specified in the call to RequestMessage.send.
        %
        %   This property is useful for delegates that may wish to access properties
        %   of their parent consumers, for example to determine who delegated to them.
        %
        % See also GenericConsumer, MultipartConsumer, matlab.net.http.RequestMessage
        MyDelegator     matlab.net.http.io.ContentConsumer
    end
    
    methods (Abstract, Access=protected)
        % START Signal start of transfer and return buffer size
        %   BUFSIZE = START(CONSUMER) is called by MATLAB when it is about to send
        %   data to the consumer, after it has called initialize that returned true.
        %   All consumers must implement this abstract method. The consumer should
        %   return the maximum size of the data buffer that MATLAB should pass in on
        %   each call to putData, although MATLAB may pass in a smaller size. 
        %   Consumers that can always process all of the data immediately, regardless
        %   of the size, can return [] to let MATLAB choose the best size. Specifying
        %   a smaller size is useful for slowly arriving data, as it allows you to
        %   receive data in a more timely manner rather than waiting for a large
        %   buffer to be filled. 
        %
        %   If the server sends chunked-encoded messages and the data is not being
        %   decompressed (or HTTPOptions.DecodeReponse is false), and you want to be
        %   sure that each call to putData contains a whole chunk, return [] or a value
        %   larger than the maximum chunk size. In this case MATLAB will never provide
        %   more than a single chunk at a time in one call to putData, but it may
        %   provide a part of a chunk if the chunk is larger than BUFSIZE or MATLAB's
        %   internal buffer size.
        %
        %   This method differs from initialize in that it is invoked only if the
        %   message contains a payload, whereas initialize is called as soon as the
        %   header of the message is received. Hence, it may be better to perform
        %   costly initializations in this method rather than initialize, so it is not
        %   done if the message is empty.
        %
        %   MATLAB calls START only once after INITIALIZE. However a subclass or
        %   delegator may call this method more than once per message to restart
        %   processing of the data using possibly different options, perhaps after an
        %   error.
        %
        % See also initialize, putData, Response, HTTPOptions
        bufsize = start(obj)
    end
    
    methods 
        function set.CurrentLength(obj, value)
            if ~isempty(value) && ~isscalar(value)
                validateattributes(value, {'uint64'}, {'scalar'}, mfilename, 'CurrentLength');
            end
            obj.CurrentLength = value;
        end
        
        function set.Response(obj, response)
        % When setting Response, copy the Data and Payload into the DataInt and
        % PayloadInt properties, so that we don't alter the Body.ContentType
            if isempty(response) 
                obj.ResponseInt = response;
            else
                obj.ResponseInt.StatusLine = response.StatusLine;
                obj.ResponseInt.Header = response.Header;
                if isempty(response.Body)
                    obj.ReponseInt.Body = obj.Response.Body;
                else
                    obj.ResponseInt.Body.DataInt = response.Body.Data;
                    obj.ResponseInt.Body.PayloadInt = response.Body.Payload;
                end
            end
        end
        
        function response = get.Response(obj)
            response = obj.ResponseInt;
        end
        
        
        function [size, stop] = putData(obj, data)
        % putData Process or store next buffer of data
        %   [SIZE, STOP] = putData(CONSUMER, DATA) is called by MATLAB to provide a
        %   buffer of DATA (uint8 vector) read from the server to the CONSUMER, a
        %   ContentConsumer. Subclass consumers should override this method to receive
        %   streamed data. Your consumer should return the length of data that it
        %   actually processed in SIZE, and a true/false indication in STOP to specify
        %   whether it wants to receive further data from this message.
        %
        %   If DATA is empty (see below) it means the message or message part (in the
        %   case of a multipart message) has ended.
        %
        %   If STOP is true, MATLAB will stop processing the rest of the message
        %   (including any subsequent parts of a multipart message being processed by
        %   MultipartConsumer) silently proceeding as if the end of the message has been
        %   reached, even if the message has more data. This will immediately close the
        %   connection to the server and no error will be returned to the caller of
        %   RequestMessage.send. This is not considered an error condition and is the
        %   normal way to gracefully terminate receipt of an arbitrary-length stream. If
        %   STOP=true MATLAB and DATA is not already empty, MATLAB will make one
        %   additional call to putData with empty DATA. STOP=true may be set whether or
        %   not DATA is empty.
        %
        %   Consumers should not normally set STOP=true at the end of DATA, because, if
        %   they are multipart delegates, that would terminate processing for the rest
        %   of the message. To terminate processing just for their own part of the
        %   message, consumers should return SIZE < 0 to indicate they do not want to
        %   receive more data for their part (see below).
        %
        %   Values of SIZE: 
        %
        %     SIZE >= 0, SIZE <= length(DATA)
        %         The number of bytes of DATA processed by this call to putData. The
        %         number is used only for the benefit of subclasses of this consumer
        %         that may wish to know how much data was processed. It has no effect
        %         on future calls to putData. SIZE is ignored if DATA is empty.
        %
        %     SIZE < 0
        %         Same as above, where abs(SIZE) is the number of bytes processed. But
        %         in addition, MATLAB will silently skip the remainder of the data,
        %         making one more call to putData(uint8.empty) at the end of the data.
        %         This value should be returned by consumers that have partially
        %         processed data, but do not want to process the rest of the data either
        %         due to an error in the data or some other criteria. Whether or not
        %         there is any data in the Response or elsewhere, prior to reaching the
        %         normal end of data, depends on the consumer. If a MultipartConsumer
        %         is not being used, this is similar to returning STOP=true, except for
        %         the additional call to putData at the end. If MultipartConsumer is
        %         being used, a negative value of SIZE only ends the part, and does not
        %         affect processing of subsequent parts of the message, so the
        %         connection is not closed until the next part or end of message is
        %         reached.
        %         
        %     SIZE = []  (empty double)
        %         The consumer has decided something went wrong with the transfer and
        %         further transfers from the server should be terminated. This is
        %         similar to STOP=true, but it is considered an error. MATLAB will make
        %         one more call to putData(uint8.empty), and then throw a generic
        %         HTTPException to the caller of RequestMessage.send, indicating that the
        %         consumer aborted the connection. In this case the only way the caller
        %         can get the partially-processed ResponseMessage is through
        %         HTTPException.History.
        %
        %         As an alternative to returning SIZE=[] to throw a standard exception,
        %         your putData can directly throw its own exception, which MATLAB will
        %         wrap as a cause in an HTTPException thrown by RequestMessage.send.
        %
        %   Values of DATA:
        %    
        %     nonempty uint8 vector  
        %         A normal buffer of data to read from the server
        %
        %     uint8.empty            
        %         End of data. This is the normal way MATLAB indicates the response
        %         message has ended. This is an indication for the consumer to clean up
        %         (e.g., delete temporary files, truncate response data to current
        %         length, etc.) and be prepared for a possible future call to
        %         initialize for a subsequent message. In response, the consumer should
        %         return STOP=true and SIZE=0 to indicate that processing was successful
        %         with no new bytes processed. If a consumer returns SIZE=[], this
        %         indicates the consumer had a problem finalizing the data and MATLAB
        %         will throw an HTTPException back to the caller of RequestMessage.send.
        %
        %     [] (empty double)     
        %         The server, a network problem, or the user (using Ctrl+C) aborted the
        %         transfer. The consumer should generally clean up exactly as if
        %         uint8.empty was received, but some consumers may wish to delete any
        %         incomplete data already received. On return from putData(), MATLAB
        %         will throw an HTTPException whose History.Response contains any data
        %         that the consumer stored in its Response property.
        %
        %     Most consumers that do not care about the difference between [] and
        %     uint8.empty can simply check isempty(DATA) and clean up appropriately. In
        %     every case where DATA is empty, consumers MUST call their superclass putData
        %     with that same empty value, even if they are not using their superclass
        %     putData to store data, as that is the only way the superclass knows to clean
        %     up. After receiving an empty value of DATA, implementations must ignore
        %     subsequent calls to putData with empty values, until the next call to
        %     start(). Typically they should just return STOP=false and SIZE=0 on
        %     subsequent calls and not carry out any additional processing.
        %
        %   If you create a subclass of a consumer that implements this method, your
        %   putData method may want to call its superclass putData in order to take
        %   advantage of any conversions or processing that the superclass implements.
        %
        %   MATLAB limits the size of DATA buffers to the BUFSIZE returned by start or
        %   an internal buffer size if BUFZIZE was []. Additionally, if the server sends
        %   a chunk-encoded message, a given call to putData will never provide more
        %   than one chunk. This allows the consumer to obtain slowly arriving chunks
        %   in a timely manner even if BUFSIZE is much larger than the chunk size.
        %
        %   Default behavior of putData() in this base class:
        %
        %   Subclass consumers have the option of storing their (possibly converted)
        %   content directly in Response.Body.Data, either incrementally or all at once,
        %   or disposing of it in some other way--they need not call this putData method
        %   to store data. As a convenience, consumers that want to store content
        %   incrementally in Response.Body.Data can call this method to do so. This
        %   method appends DATA to Response.Body.Data using the AppendFcn, attempting to
        %   do so efficiently by incrementally allocating capacity. The actual length of
        %   stored data is maintained in the CurrentLength property, which may be
        %   smaller than the actual length of Response.Body.Data. At the end of the
        %   transfer (i.e., when putData(CONSUMER,[]) or putData(CONSUMER,uint8.empty)
        %   is called, Response.Body.Data is truncated to CurrentLength. You may define
        %   our own AppendFcn to implement an alternative append method.
        %
        %   By default this method always returns SIZE equal to the numel(DATA) and
        %   STOP equal to false.
        %
        %   If you intend to use this method to store data and know the maximum length
        %   of data to be stored, you should set Response.Body.Data to a vector of the
        %   desired size filled with default values (e.g., zeros), prior to calling
        %   this method for the first time. This method will start storing data at
        %   the beginning of your data area and then truncate it to the length of data
        %   at the end of the message, maintaining the length of data stored in
        %   CurrentLength.
        %
        %   Consumers that call this method in this base class to incrementally store
        %   data may provide DATA of any type that supports horzcat or vertcat,
        %   including structures and cell arrays. If you provide a cell array, the
        %   existing Data will be converted to a cell array if it is not already, and
        %   elements of the cell array will be inserted into the existing cell array at
        %   the linear index beginning at CurrentLength+1.
        %
        %   If you call this method in ContentConsumer to store data you should let this
        %   method manage Response.Body.Data or CurrentLength and not modify them
        %   directly.
        %
        %   ContentConsumers that call this method in their superclass should be
        %   prepared to do any cleanup, such as closing windows or deleting temporary
        %   files, if the superclass throws an exception.
        %
        % See also start, Response, CurrentLength, AppendFcn, MultipartConsumer,
        % matlab.net.http.RequestMessage, matlab.net.http.ResponseMessage,
        % matlab.net.http.HTTPException, matlab.net.http.HTTPOptions
            stop = false; % this base class never sets STOP
            if isempty(obj.ResponseInt.Body)
                obj.ResponseInt.Body = matlab.net.http.MessageBody;
            end
            if isempty(data) 
                % Done with message; data is uint8.empty or [].
                if isscalar(obj.ResponseInt.Body)
                    obj.ResponseInt.Body.ContentType = obj.ContentType;
                end
                size = 0;
                % Need to set this because we might have been called from subclass, not
                % putDataInternal. Normally putDataInternal sets this in case overridden
                % putData fails to.
                obj.InUse = false;
            else
                if ~obj.InUse
                    error(message('MATLAB:http:NotInitialized', class(obj)));
                end
                % size of new data
                size = numel(data);
            end
            % append new data using the AppendFcn or our default
            if isempty(obj.AppendFcn)
                obj.append(data);
            else
                obj.AppendFcn(obj, data);
            end
        end
        
        function tf = isequal(obj,other)
            tf = strcmp(class(obj),class(other)) && numel(obj)==numel(other);
            % Two different consumers will compare false because AppendFcn points to
            % different function instances. To fix, structify the objects and replace
            % AppendFcn with the string equivalents. This might compare objects equal that
            % really aren't, if different function handles stringify the same.
            if tf
                oldwarn = warning('off','MATLAB:structOnObject');
                clean = onCleanup(@()warning(oldwarn.state,oldwarn.identifier));
                replaceField = @(s)setfield(s,'AppendFcn',func2str(s.AppendFcn)); 
                this = arrayfun(replaceField,struct(obj)); 
                them = arrayfun(replaceField,struct(other)); 
                tf = isequal(this,them);
            end
        end
    end
    
    methods (Access=protected)
        function ok = initialize(obj)
        % INITIALIZE Prepare this object for use with a new payload
        %   OK = INITIALIZE(CONSUMER) is called by MATLAB after receipt of the header
        %   of a ResponseMessage that may contain a payload, to prepare the consumer
        %   for that payload. It is not invoked for messages not expected to contain
        %   a payload, such as those with an explicit Content-Length of 0, or in error
        %   cases where a complete header was not received.
        %
        %   The return value OK is a logical indicating whether the consumer wants
        %   to accept or reject the payload of the message. Default is true if the
        %   status code of the ResponseMessage is StatusCode.OK.
        %
        %   If OK is true, the consumer has accepted the message and is expected to
        %   process the payload, if any. MATLAB will call the consumer's start method
        %   when the first byte of the payload has arrived, followed by one or more
        %   calls to putData, passing in a buffer of data on each call. If OK is
        %   false, this indicates that the consumer does not want to process the
        %   message, in which case MATLAB will process the payload as if no consumer
        %   had been specified (which may mean default conversion of payload to data).
        %   If you override this method and reject the message, and you want to abort
        %   receipt of the message instead of processing it in a default manner, throw
        %   an error from this method instead of returning false.
        %
        %   Even if INITIALIZE is called, MATLAB may not call the consumer's start
        %   method if the message has no payload.
        %
        %   This method is also called in the delegate consumer by the delegateTo
        %   method.
        % 
        %   ContentConsumer subclasses may wish to override this method to initialize
        %   their own properties and to determine if they want to process the payload,
        %   or to process a payload that has a StatusCode other than OK. Most
        %   consumers should at least check ContentType to verify that the response is
        %   of the type they are prepared to handle. It is up to you whether to
        %   perform any subsequent initializations in this method or delay them until
        %   the start method.
        %
        %   This method has a default implementation that returns true if
        %   Response.StatusCode is StatusCode.OK and false otherwise. Subclasses that
        %   override this method should invoke this superclass method first and check
        %   the return value, unless they want to process messages with a status other
        %   than OK. Subclasses that invoke putData in this class must call this
        %   method.
        %
        %   Consumer subclasses should be prepared to be reused for subsequent
        %   messages. MATLAB will call INITIALIZE prior to each message and then
        %   start for each message that has a nonempty payload. Once MATLAB calls
        %   start, it will not call INITIALIZE until the message has ended, an exception
        %   was thrown, or an interrupt occurred during message processing. All of
        %   these cases are indicated by a call to putData(uint8.empty).
        %
        % See also start, putData, CurrentLength, matlab.net.http.StatusCode,
        % delegateTo, Response, matlab.net.http.RequestMessage
            ok = obj.ResponseInt.StatusCode == matlab.net.http.StatusCode.OK;
            obj.InUse = ok;
        end
    end
    
    methods (Access=protected)
        function [ok, bufsize] = delegateTo(obj, delegate, header)
        % delegateTo Delegate to another consumer 
        %   [OK, BUFSIZE] = delegateTo(CONSUMER, DELEGATE, HEADER) prepares the
        %   specified DELEGATE as a consumer to process subsequent payload based on
        %   HEADER. DELEGATE is a ContentConsumer, or a handle to a function taking no
        %   arguments that returns one. CONSUMER becomes the delegator and DELEGATE
        %   becomes the delegate.
        %
        %   This method prepares the delegate by setting its properties such as Request,
        %   Response, URI, etc. to those of CONSUMER, and its Header to the value of
        %   HEADER. It sets CONSUMER.CurrentDelegate to DELEGATE and
        %   DELEGATE.MyDelegator to CONSUMER. It then calls the delegate's initialize
        %   method, and if that returns true (indicating the delegate accepts the
        %   message), calls the start method. 
        %
        %   If OK is true, it is the responsibility of the caller to explicitly invoke
        %   DELEGATE.putData to feed data to the delegate, and, if desired, to copy any
        %   data that the delegate inserts in its Response.Body back into the caller's
        %   Response, on each call or before switching to a new delegate or at the end
        %   of the message.
        %
        %   Do not call delegateTo in a different delegate without telling the first
        %   delegate that the data has ended (by calling DELEGATE.putData(uint8.empty),
        %   which normally happens at the end of the data).
        %
        %   If OK is false, or the previous delegate has been told that the data has
        %   ended, a consumer can issue delegateTo to invoke another delegate for
        %   subsequent (or the same) data in the same message.
        %
        %   OK and BUFSIZE are the values returned by the delegate's initialize and
        %   start methods, respectively. BUFSIZE is valid only if OK is true. If OK is
        %   false, the delegate's start method has not been called and this consumer
        %   should not invoke putData in that delegate.
        %
        % See also MultipartConsumer, GenericConsumer, Header, CurrentDelegate, MyDelegator,
        % initialize, start
            validateattributes(delegate, {'function_handle','matlab.net.http.io.ContentConsumer'}, ...
                {'scalar'}, [mfilename '.delegateTo'], 'DELEGATE');
            try 
                delegate = obj.instantiateDelegate(delegate, header);
                % Initialize the delegate using our properties but with the specified header
                delegate.setProperties(obj.AllocationLength, obj.URI, obj.Request, ...
                                       obj.ResponseInt, header, obj.SavePayload);
                ok = delegate.initializeInternal();
                if (ok)
                    bufsize = delegate.startInternal();
                    obj.CurrentDelegate = delegate;
                    delegate.MyDelegator = obj;
                else
                    bufsize = [];
                end
            catch e
                if isa(delegate,'matlab.net.http.io.ContentConsumer') && ~isempty(delegate.Exception)
                    obj.Exception = delegate.Exception;
                end
                throw(e);
            end
        end
    end
    
    methods (Access=private) 
        function append(obj, data)
        % append Append buffer of data to message body
        %   append(CONSUMER, DATA) is the default AppendFcn for ContentConsumer. It
        %   appends DATA to Response.Body.Data using linear indexing, efficiently
        %   growing the response buffer using preallocation. During transfer,
        %   previously appended data is at Response.Body.Data(1:CONSUMER.CurrentLength).
        %   If DATA is empty, Response.Body.Data is truncated to CurrentLength.
        %
        % See also Response, AppendFcn, CurrentLength   
            if isempty(data) 
                % end of data; truncate Data to current length
                if ~isempty(obj.CurrentLength)
                    obj.ResponseInt.Body.DataInt(obj.CurrentLength+1:end) = [];
                end
            else
                if obj.CurrentLength > length(obj.ResponseInt.Body.Data)
                    % in case user changed CurrentLength to be greater than length of Data, set it
                    % back to Data length
                    obj.CurrentLength = length(obj.ResponseInt.Body.Data);
                end
                if isempty(obj.ResponseInt.Body.Data)
                    % no data stored yet; initialize it to data plus padding
                    if iscell(data) || isobject(data)
                        minSize = 20;
                    else
                        minSize = 8192;
                    end
                    newLength = length(data);
                    if minSize > length(data)
                        if iscell(data) 
                            data{minSize} = [];
                        else
                            % dirty trick: expand data by copying last element to end
                            data(minSize) = data(end);
                        end
                    end
                    obj.ResponseInt.Body.DataInt = data;
                else
                    % We already have Data; need to add data to it
                    if iscell(data) && ~iscell(obj.ResponseInt.Body.Data)
                        % If new data is cell but Data wasn't, convert old Data to cell array. This is
                        % to handle the case where the user really wants a cell array, but happens to
                        % store the first several elements not wrapped in cells. 
                        obj.ResponseInt.Body.DataInt = num2cell(obj.ResponseInt.Body.Data);
                    elseif iscell(obj.ResponseInt.Body.Data) && ~iscell(data)
                        % Old Data is cell but new data is not, so put new data in a single cell
                        data = {data};
                    end
                    % This is how long new Data needs to be to hold additional data
                    newLength = obj.CurrentLength + length(data);
                    if newLength > length(obj.ResponseInt.Body.Data)
                        if iscell(data) || iscell(obj.ResponseInt.Body.Data)
                            minSize = 20;
                        else
                            minSize = 8192;
                        end
                        % if data won't fit in current Data need to increase the size
                        % expand Data to max of twice current length, sizeNeeded, or minSize
                        allocSize = max([obj.CurrentLength*2, newLength, minSize]);
                        % expand Data by setting newSize element
                        if iscell(obj.ResponseInt.Body.Data) 
                            % expand cell array with empty cells
                            obj.ResponseInt.Body.DataInt{allocSize} = [];
                        else
                            obj.ResponseInt.Body.DataInt(allocSize) = obj.ResponseInt.Body.Data(end);
                        end
                    end
                    % fill data beginning at CurrentLength
                    obj.ResponseInt.Body.DataInt(obj.CurrentLength + 1 : newLength) = data;
                end
                obj.CurrentLength = newLength;
            end
        end
        
        function consumer = instantiateDelegate(~, consumer, header)
        % Return or instantiate a delegate consumer. If consumer is an object, return
        % it. If not, assume it's a function to return an object, throwing an error
        % if the return value is not a ContentConsumer. header is used just for error
        % reporting. This doesn't call any methods in the consumer except for the
        % constructor.
        %
        % Caller is expected to have verified that consumer is either a
        % ContentConsumer or a function handle returning at least 1 value.
            if ~isobject(consumer)
                % if consumer is not a ContentConsumer, then it's a function handle to
                % construct one
                try
                    consumer = consumer();
                catch e
                    me = MException(message('MATLAB:http:CannotConstructConsumer', ...
                                            char(consumer), getType()));
                    me.addCause(e);
                    throw(me);
                end
                if ~isa(consumer, 'matlab.net.http.io.ContentConsumer')
                    str = message('MATLAB:http:DelegateForType', getType(), char(consumer));
                    validateattributes(consumer, {'matlab.net.http.io.ContentConsumer'}, ...
                                       {'scalar'}, mfilename, str.getString);
                end
            end
            function ct = getType()
                ctf = header.getValidField('Content-Type');
                ct = '*/*';
                if ~isempty(ctf)  
                    ct = ctf(1).convert();
                    ct = ct.Type + '/' + ct.Subtype;
                end
            end

        end
        
        % The "Internal" functions below are called only from within this class or
        % InterruptibleStreamCopier.cpp. They implement callouts to similar methods in
        % this class that may be overridden, but implement behavior that we don't want
        % the subclass to suppress.
        
        function len = startInternal(obj)
        % Called from InterruptibleStreamCopier or delegateTo() when there is data that
        % was read from network, to say that transfer is starting. Calls start() and
        % returns its value:
        %   >0   Desired buffer size
        %   []   Let MATLAB choose buffer size
            obj.InUse = true;
            try
                % This calls start() in subclass
                len = obj.start();
                if ~isempty(len)
                    if (~isscalar(len) || ~isreal(len) || ~isnumeric(len) || len <= 0) 
                        msg = message('MATLAB:http:BadReturnValueFromMethod', 'start');
                        validateattributes(len, {'numeric'}, {'scalar', 'real', '>', 0}, class(obj), msg.getString);
                        assert(false) % if we get here condition in if does not match validateattributes test
                    else
                    end
                end
                obj.Exception = MException.empty;
            catch e
                % InterruptibleStreamCopier will abort without having read any payload.  
                obj.InUse = false;
                obj.Exception = e;
                % This exception tells RequestMessage to get the real exception to throw from
                % obj.Exception.
                error(message('MATLAB:webservices:OperationTerminatedByConsumer', char(obj.URI)));
            end
        end
        
        function closeInternal(obj)
        % Called when end of stream encountered or any exception has occurred in
        % InterruptibleStreamCopier.
            try
                % this may call subclass's implementation
                obj.putDataInternal(uint8.empty);
                % reset this in case above doesn't do so
                obj.InUse = false;
            catch e
                obj.InUse = false;
                rethrow(e);
            end
        end
        
        function interruptInternal(obj)
            obj.putDataInternal([]);
        end
    end
    
    methods (Access=?matlab.net.http.RequestMessage)
        function len = putDataInternal(obj, data)
        % Called from InterruptibleStreamCopier to send each buffer of data to the
        % consumer. Calls putData() in this consumer and returns an indication whether to
        % end the message. Note this function is not called in a delegate:
        % MultipartConsumer and GenericConsumer call putData directly.
        %
        % This function is a no-op if setProperties was never called.
        %
        %
        %  len == length(data)     data processed; continue normally. Returned if
        %                          putData returns SIZE >= 9.
        %  len == []               abnormal abort; throw obj.Exception without saving
        %                          payload, even if SavePayload set. Returned if
        %                          putData throws or returns [].
        %  0 <= len < length(data) processed len bytes; close connection and save data
        %                          in payload. Returned when putData sets STOP, returns
        %                          negative SIZE, or throws an exception. len is
        %                          abs(SIZE), but at most length(data)-1. If there was
        %                          an exception, obj.Exception has the exception, which
        %                          user will get as an HTTPException. If not, there is
        %                          no exception.
        %
        % This function doesn't distinguish between STOP and SIZE < 0, since both end
        % the connection immediately.
        %
        % Just delegates call to putData, and checks validity of return argument. 
            if isempty(obj.ResponseInt)
                % If there is no Response, we were never even initialized by setProperties, so
                % just pretend nothing happened. This can happen if a cleanup handler called
                % putData(uint8.empty) to clean us up, but we were never initialized.
                return;
            end
            obj.PayloadLength = obj.PayloadLength + length(data);
            try
                if isempty(data) && ~isempty(obj.Exception)
                    try
                        [size, stop] = obj.putData(data);
                    catch
                        size = 0;
                        stop = false;
                    end
                else
                    [size, stop] = obj.putData(data);
                end
                if ~isempty(size) && (~isscalar(size) || ~isreal(size) || ~isnumeric(size))
                    % Bad return value from putData. The exception this throws will be caught
                    % below and saved in Exception.
                    msg = message('MATLAB:http:BadReturnValueFromMethod', 'putData');
                    validateattributes(size, {'numeric'}, {'scalar', 'real'}, class(obj), msg.getString);
                end
                len = length(data); 
                if isempty(size) || stop || size < 0
                    % putData says silently stop or throw a standard error. When empty len is returned to
                    % caller (InterruptibleStreamCopier) will throw a terminated exception to the
                    % user.
                    obj.InUse = false;
                    if isempty(size)
                        % this causes standard error to be thrown to user
                        obj.Exception = MException.empty;
                        len = []; 
                    else
                        % Stop is set and size is not empty: we need to stop without an error and saves
                        % the payload if SavePayload set, so return a length smaller than data to tell
                        % InterruptibleStreamCopier that we should end gracefully.
                        len = abs(size);
                        if len >= length(data)
                            len = length(data)-1;
                        end
                    end
                end
            catch e
                % On any exception for putData, we're no longer in use. Save the exception so 
                % RequestMessage.send can throw it to the user in the form of an HTTPException
                % that contains the partially-processed ResponseMessage. It won't have a
                % Payload, even if SavePayload is set, because a return value of [] causes
                % InterruptibleStreamCopier to abort with an exception, so it can't return
                % its output buffer to MATLAB.
                obj.InUse = false;
                % If an exception was already saved, use that, as it's more likely to be the
                % real cause.
                if isempty(obj.Exception)
                    obj.Exception = e;
                end
                len = [];
            end
        end
        
        function savePayloadInternal(obj, payload)
        % Called from C++ when there was an exception thrown during processing, if
        % SavePayload was set.  Also called by RequestMessage at the normal end of the
        % message. Saves the payload in this object's Response.Body.Payload, if
        % currently empty. We in turn call this in our delegate, if any.  Note
        % MultipartConsumer clears CurrentDelegate at the end of the message, so we only
        % invoke the delegate if it is still set (as is the case for GenericConsumer,
        % for example).
            if isempty(obj.Response.Body.Payload)
                obj.Response.Body.PayloadInt = payload;
                if ~isempty(obj.CurrentDelegate)
                    obj.CurrentDelegate.savePayloadInternal(payload);
                end
            end
        end
    end
    
    methods (Access={?matlab.net.http.internal.HTTPConnector})
        function ok = initializeInternal(obj)
        % Called from HTTPConnector when ready to receive response
            try
                % This will call out to subclass, which may in turn call super.initialize(),
                % which will set InUse if status code is OK.
                ok = obj.initialize();
                % But in case it doesn't call superclass, set InUse if response is ok.
                obj.InUse = ok;
            catch e
                % In case subclass initialize() throws after calling super.initialize(), make
                % object not in use again.
                obj.InUse = false;
                obj.Exception = e;
                % This exception tells RequestMessage to get the real exception to throw from
                % obj.Exception.
                error(message('MATLAB:webservices:OperationTerminatedByConsumer', char(obj.URI)));
            end
        end
    end
    
    methods (Access={?matlab.net.http.RequestMessage,?matlab.net.http.internal.HTTPConnector})
        function setProperties(obj, allocationLength, uri, request, response, header, savePayload)
        % Initialize this consumer for a new payload by setting its properties
            if obj.InUse
                error(message('MATLAB:http:AlreadyInUse', class(obj)));
            end
            obj.ContentType = [];
            obj.ContentLength = [];
            obj.AllocationLength = allocationLength;
            obj.URI = uri;
            obj.Request = request;
            obj.ResponseInt = response;
            obj.ResponseInt.Body = matlab.net.http.MessageBody;
            obj.Header = header;
            obj.CurrentDelegate = [];
            obj.SavePayload = savePayload;
            if ~isempty(obj.Header)
                ctf = obj.Header.getValidField('Content-Type');
                if ~isempty(ctf)
                    mt = ctf(end).convert();
                    if isstring(mt)
                        obj.ContentType = matlab.net.http.MediaType;
                        obj.ContentType.Type = mt;
                    else
                        obj.ContentType = mt;
                    end
                end
                clf = obj.Header.getValidField('Content-Length');
                if ~isempty(clf)
                    obj.ContentLength = clf(end).convert();
                end
            end
            obj.CurrentLength = [];
            obj.PayloadLength = 0;
        end
        
        function clearProperties(obj)
        % Clear all the properties pertaining to a given message; called when this
        % consumer is applied to a message. Clears everything set by setProperties.
            obj.ContentType = [];
            obj.ContentLength = [];
            obj.AllocationLength = [];
            obj.URI = [];
            obj.Request = matlab.net.http.RequestMessage.empty;
            obj.ResponseInt = matlab.net.http.ResponseMessage.empty;
            obj.Header = [];
            obj.CurrentDelegate = [];
            obj.CurrentLength = [];
            obj.PayloadLength = 0;
            obj.SavePayload = false;
        end 
    end
    
    methods (Static, Sealed, Access = protected)
        function default_object = getDefaultScalarElement
            default_object = matlab.net.http.io.internal.DefaultConsumer;
        end
    end

end