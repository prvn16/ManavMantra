classdef JSONProvider < matlab.net.http.io.StringProvider
% JSONProvider ContentProvider that sends MATLAB data as a JSON string
%   This is a ContentProvider that converts MATLAB data to a JSON string and
%   sends it in a RequestMessage. Conversion is done using jsonencode.
%
%   If the RequestMessage contains no Content-Type header field, this provider
%   adds one specifying "application/json". Otherwise the header field will be
%   left alone and conversion will be done even if its value is inconsistent
%   with JSON data.
%
%   For non-multipart messages, you do not usually need to specify this provider
%   explicitly, as the contents of MessageBody.Data is automatically converted
%   to JSON if the Content-Type of the message is application/json. For more
%   information, see MessageBody.Data. Specify this provider explicitly to send
%   JSON data for other Content-Types, or to send JSON data as a part in a
%   multipart message.
%
%   JSONProvider properties:
%     JSONData        - the MATLAB data to be converted
%
%   JSONProvider methods:
%     JSONProvider    - constructor
%     string          - return contents as JSON string
%
%   For subclass authors
%   --------------------
%
%   JSONProvider methods (overridden from superclasses):
%     complete        - complete the header
%     start           - start a new transfer
%
% See also ContentProvider, StringProvider, matlab.net.http.RequestMessage, jsonencode,
% matlab.net.http.MessageBody


% Copyright 2017 The MathWorks, Inc.
    properties (Dependent)
        % JSONData - the MATLAB data to be converted
        %   This is the value specified to the constructor, if any. 
        %
        %   Subclass authors may set this value at any time prior to MATLAB's call to
        %   START. If you change this, it won't take effect until the next call to
        %   START.
        %
        % See also start
        JSONData % dependent because set.JSONData accesses Data
    end
    
    properties (Access=private)
        RealJSONData
    end
    
    methods
        function set.JSONData(obj, value)
            obj.RealJSONData = value;
            obj.Data = [];
        end
        
        function value = get.JSONData(obj)
            value = obj.RealJSONData;
        end
        
        function obj = JSONProvider(data)
        % JSONProvider ContentProvider that converts data to JSON
        %   PROVIDER = JSONProvider(DATA) constructs a ContentProvider that converts
        %   MATLAB DATA to JSON.
            if nargin > 0
                obj.JSONData = data;
            end
        end
        
        function str = string(obj)
            obj.setData();
            str = obj.string@matlab.net.http.io.StringProvider();
        end
    end
    
    methods (Access=protected)
        function complete(obj, varargin)
        % complete Complete the header of the message
        %   complete(PROVIDER, URI) is an overridden method of StringProvider that
        %   completes the header of the message, or (in the case of a multipart message)
        %   the part for which this provider is being used. If there is no Content-Type
        %   field, it adds one specifying "application/json". If there is already a
        %   Content-Type field that does not contain a charset parameter, and this
        %   object's Charset is different from the default for that Content-Type, then a
        %   charset parameter is added to the header field.
        %
        % See also matlab.net.http.io.StringProvider.complete
            
            % Add a ContentTypeField to header 
            ctf = obj.Header.getValidField('Content-Type');
            if isempty(ctf)
                % If there is no Content-Type field, add one
                obj.Header = obj.Header.addFields(matlab.net.http.field.ContentTypeField(...
                    'application/json'));
            else
                mt = ctf.convert();
                if ~isempty(mt)
                    mtcs = mt.getParameter('charset');
                    if isempty(mtcs)
                        % no explicit charset parameter
                        cs = matlab.net.internal.getCharsetForMediaType(mt);
                        if isempty(obj.Charset)
                            ourmt = matlab.net.http.MediaType('application/json');
                            ourcs = matlab.net.internal.getCharsetForMediaType(ourmt);
                        else
                            ourcs = obj.Charset;
                        end
                        if isempty(cs) || ~strcmpi(cs, ourcs)
                            % The Content-Type field has no explicit charset and its default charset is not
                            % the same as our default so add our default.
                            mt = mt.setParameter('charset',ourcs);
                            ctf.Value = mt;
                            obj.Header = obj.Header.replaceFields(ctf);
                        end
                    end
                end
            end
            % The StringProvider will encode the characters according to the explicit or
            % default charset for the Content-Type
            obj.complete@matlab.net.http.io.StringProvider(varargin{:});
        end
        
        function start(obj)
        % START Start a new transfer
        %   START(PROVIDER) is an overridden method of ContentProvider that MATLAB calls
        %   to prepare this provider for new transfer.
        % 
        % See also matlab.net.http.io.StringProvider.start

            % Since we can't actually stream the encoding (yet), convert the data now and
            % set it in the StringProvider's Data property all at once. This conversion
            % happens just once, until JSONData changes.
            obj.setData();
            obj.start@matlab.net.http.io.StringProvider();
        end
        
        function len = expectedContentLength(obj, varargin)
            if ~isempty(varargin) && varargin{1}
                % convert data to JSON, if forced
                obj.setData();
                if isempty(obj.Charset)
                    % If Charset wasn't set yet, this method was called prior to complete().
                    % While we don't promise to return a valid result in that case, set the charset
                    % temporarily to the default so that StringProvider can tell the length.
                    [~, obj.Charset] = obj.getCharset();
                    len = obj.expectedContentLength@matlab.net.http.io.StringProvider(varargin{:});
                    % Undo this so that complete() can set the correct value later, based on
                    % headers.
                    obj.Charset = [];
                    return;
                end
            end
            len = obj.expectedContentLength@matlab.net.http.io.StringProvider(varargin{:});
        end
    end
    
    methods (Access=private)
        function setData(obj)
        % Encode JSONData and set the Data property
            if isempty(obj.Data)
                obj.Data = jsonencode(obj.JSONData);
            end
        end
        
        function [ourmt, ourcs] = getCharset(obj)
        % Return the MediaType and charset used for conversion.  If Charset is already
        % set, return that.  Otherwise, return the default for application/json.
            ourmt = matlab.net.http.MediaType('application/json');
            ourcs = matlab.net.internal.getCharsetForMediaType(ourmt);
            if ~isempty(obj.Charset) && ~strcmpi(obj.Charset, ourcs)
                % Our Charset property was set and it's different from the default for
                % application/json, so Charset overrides the default.
                ourcs = obj.Charset;
                ourmt = ourmt.setParameter('charset',ourcs);
            end
        end
    end
    
end

