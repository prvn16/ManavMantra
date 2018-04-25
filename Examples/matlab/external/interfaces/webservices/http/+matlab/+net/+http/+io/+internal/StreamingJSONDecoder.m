classdef StreamingJSONDecoder < matlab.net.http.io.internal.StreamingConverter
% StreamingJSONDecoder decodes a JSON string as it is received
%   This implements the StreamingConverter API, but the current implementation
%   does not actually convert the input until it has all been received, because
%   our jsondecode function requires the whole string.
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/http. Its behavior
%   may change, or the function itself may be removed in a future release.

% Copyright 2017 The MathWorks, Inc.

    properties
        % Because we don't actually convert until the end of the stream, we need to save
        % the input until we get to the end, and then convert
        Data string = ""
        % Converted data, set after conversion of Data; if set, Data should be ""
        ConvertedData 
    end
    
    methods
        function obj = StreamingJSONDecoder()
        end
        
        function [res, obj] = convert(obj, buf)
        % convert Implementation of StreamingConverter.convert
            if ~isempty(buf) && ~isstring(buf) && ~ischar(buf)
                validateattributes(buf, {'string' 'char'}, {'scalartext'}, mfilename, 'BUF');
            end
            if ~isempty(buf)
                obj.Data = obj.Data + buf;
                res = [];
            else
                if strlength(obj.Data) ~= 0
                    obj.ConvertedData = jsondecode(char(obj.Data));
                    obj.Data = "";
                end
                % returns previously converted data, if called again
                res = obj.ConvertedData;
            end
        end
        
        function obj = reset(obj)
            obj.Data = "";
            obj.ConvertedData = "";
        end
    end
    
end