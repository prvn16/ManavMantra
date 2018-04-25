classdef JSONConsumer < matlab.net.http.io.StringConsumer
% JSONConsumer ContentConsumer that converts JSON input into MATLAB data
%   This ContentConsumer receives messages whose content is JSON. It converts
%   the JSON data to MATLAB and stores the result in the body of the response
%   message. 
%
%   This consumer should only be applied to incoming content that is JSON (e.g.,
%   response messages or parts of multipart messages with a Content-Type of
%   application/json), though it does not check the incoming Content-Type. 
%
%   By default, MATLAB automatically converts a message with a Content-Type of
%   application/json, so you do not need to specify this consumer for that type,
%   or any other type that obviously indicates JSON. For more information, see
%   input conversions for MessageBody.Data. Specify this consumer explicitly if
%   you know that the incoming data is JSON even if the Content-Type may not
%   indicate this. For example, sometimes a file containing JSON data has a
%   name with a .txt extension. When downloading such a file the server may
%   specify a Content-Type of text/plain based on that extension, even though it
%   contains JSON data.
%
%   If an error occurs converting the data, Response.Body.Data in the HTTPException
%   thrown on the error will contain any intermediate result of the decoding process. 
%
%   JSONConsumer properties (inherited from StringConsumer):
%     Charset         - character set used to read the JSON data
%
%   JSONConsumer methods:
%     JSONConsumer    - constructor
%
%   For subclass authors
%   --------------------
%
%   JSONConsumer methods (overridden from superclasses)
%     initialize      - start a new stream
%     putData         - process next buffer of data
%  
% See also ContentConsumer, StringConsumer, jsondecode, MessageBody

% Copyright 2017 The MathWorks, Inc.
    properties (Access=private)
        % Decoder - handle to function that will be called to decode the JSON string
        Decoder matlab.net.http.io.internal.StreamingConverter = ...
                              matlab.net.http.io.internal.StreamingConverter.empty
        % DecoderArguments - arguments to decoder
        DecoderArguments cell = {};
    end
    
    methods
        function obj = JSONConsumer(decoder)
        % JSONConsumer Consumer for JSON data
        %   OBJ = JSONConsumer() creates a consumer that converts a JSON string received
        %   in a ResponseMessage to MATLAB data using jsondecode.
        %
        % See also jsondecode, matlab.net.http.ResponseMessage, ContentConsumer,
        % JSONProvider
        
        % For Internal use only:
        %   OBJ = JSONConsumer(DECODER) converts JSON data to MATLAB data using the
        %   specified DECODER, a matlab.net.http.io.internal.StreamingConverter. 
            if nargin > 0
                obj.Decoder = decoder;
            else
                obj.Decoder = matlab.net.http.io.internal.StreamingJSONDecoder;
            end
        end
        
        function [len, stop] = putData(obj, data)
        % putData Save the next buffer of data
        %   This overridden method of StringConsumer passes the data to the superclass
        %   in order to convert the uint8 buffer to a string, and then uses jsondecode
        %   to decode it and insert it into Response.Body.Data.
        %
        %   This method may not store the decoded JSON data until the entire message
        %   has been read.
        %
        %   You may override this method in order to examine or alter the uint8 data
        %   prior to conversion, or the JSON data after decoding.
        %
        % See also matlab.net.http.io.StringConsumer.putData, jsondecode
        
            % Use our decoder to convert the data, instead of calling the superclass.
            len = length(data);
            if isempty(data)
                % end of input
                % make final call to decoder, to return final data
                [jsonData, ~] = obj.Decoder.convert(data, obj.DecoderArguments{:});
                obj.putData@matlab.net.http.io.StringConsumer(data); % tell superclass we're done
            else
                % This calls StringConsumer's convert, to get Unicode string
                str = obj.convert(data);
                % Pass the converted string data to the streaming JSON decoder and get
                % intermediate result
                [jsonData, obj.Decoder] = obj.Decoder.convert(str, obj.DecoderArguments{:});
            end
            stop = false;
            % Since the decoder maintains data about intermediate state and always returns a
            % complete JSON result, always replace entire response data with the
            % intermediate or final result.
            obj.Response.Body.Data = jsonData;
            % It's length is the first dimension of jsonData
            obj.CurrentLength = size(jsonData,1); 
        end
    end
    
    methods (Access=protected)
        function ok = initialize(obj, varargin)
        % initialize Initialize for a new message
        %   OK = initialize(CONSUMER) is an overridden method of StringConsumer that
        %   MATLAB calls to prepare this consumer for receipt of a message, and returns
        %   OK if this consumer is able to process the data. This method tries to
        %   determine the charset of the data from the Content-Type in Header. If it
        %   cannot do so, it assumes UTF-8.
        %
        % See also matlab.net.http.io.StringConsumer.initialize
            ok = obj.initialize@matlab.net.http.io.StringConsumer(varargin{:});
            if ~ok && (isempty(obj.Charset) || strlength(obj.Charset) == 0)
                obj.Charset = 'utf-8';
                obj.initialize@matlab.net.http.io.StringConsumer(varargin{:});
            end
            ok = true;
        end
        
        function bufsize = start(obj)
            bufsize = obj.start@matlab.net.http.io.StringConsumer();
            if ~isempty(obj.Decoder)
                obj.Decoder = obj.Decoder.reset();
            end
        end
    end
    
end

