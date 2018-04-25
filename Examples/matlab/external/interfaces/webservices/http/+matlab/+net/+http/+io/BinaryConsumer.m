classdef BinaryConsumer < matlab.net.http.io.ContentConsumer
% BinaryConsumer Consumer for binary data in HTTP messages
%   This consumer simply copies the raw payload to Response.Body.Data. It is
%   the default consumer for GenericConsumer if no specified consumer can
%   match the type.
%
%   You would have little reason to specify this consumer directly. It is
%   provided for the benefit of subclass authors that want to examine and
%   process raw binary data while it is being received, possibly converting it
%   to MATLAB array data to be stored in Response.Body.Data.
%
%   For example, the following consumer combines each pair of uint8 bytes
%   received into an int16, and stores the int16 array in the response.
%
%    classdef MyBinaryConsumer < matlab.net.http.io.BinaryConsumer
%        properties
%            ExtraByte uint8
%        end
%        methods
%            function [len, stop] = putData(obj, data)
%                if isempty(data)
%                    [len, stop] = obj.putData@matlab.net.http.io.BinaryConsumer(data);
%                else
%                    if ~isempty(obj.ExtraByte)
%                        data = [obj.ExtraByte; data];
%                    end
%                    len = length(data);
%                    if mod(len,2) > 0
%                        obj.ExtraByte = data(end);
%                        len = len - 1;
%                    else
%                        obj.ExtraByte = uint8.empty;
%                    end
%                    res(1:len/2) = bitshift(uint16(data(1:2:len)),8)+uint16(data(2:2:len));
%                    [len, stop] = obj.putData@matlab.net.http.io.BinaryConsumer(res);
%                end
%            end
%        end
%        methods(Access=protected)
%            function bs = start(obj)
%                obj.ExtraByte = uint8.empty;
%                bs = obj.start@matlab.net.http.io.BinaryConsumer();
%            end
%        end
%    end
%
%   BinaryConsumer methods (overridden from superclass):
%      start        - start a new transfer
%      putData      - store next buffer of data
%      
% See also ContentConsumer, GenericConsumer, Response

% Copyright 2016-2017 The MathWorks, Inc.

    methods (Access=protected)
        function len = start(~)
        % START start receipt of an image
        %   BUFSIZE = START(CONSUMER) is an abstract method of ContentConsumer that MATLAB
        %   calls to indicate that receipt of data is about to start. This method
        %   always returns [] to indicate there is no preferred buffer size.
        %
        % See also matlab.net.http.io.ContentConsumer.start
            len = [];
        end
    end
    
    methods
        function [len, stop] = putData(obj, data)
        % putData Store next buffer of data
        %   [LEN, STOP] = putData(CONSUMER, DATA) is an overridden method of
        %   ContentConsumer that stores the next buffer of data. When MATLAB calls this
        %   function it provides data as a uint8 vector. This function appends the
        %   vector at the position CurrentLength+1 in Response.Body.Data, increasing the
        %   size of Data, if necessary, to make room for future data.
        %
        %   If you call this to store your own data, you may provide data of any type
        %   that is compatible with data already in Response.Body.Data.
        %
        % See also Response, CurrentLength, matlab.net.http.io.ContentConsumer.putData
            [len, stop] = obj.putData@matlab.net.http.io.ContentConsumer(data);
        end
    end
end