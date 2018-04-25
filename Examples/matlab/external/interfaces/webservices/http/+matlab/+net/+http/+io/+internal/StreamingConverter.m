classdef (Abstract) StreamingConverter < matlab.mixin.Heterogeneous
% StreamingConverter A generic streaming converter interface.
%   A StreamingConverter is an object that converts a stream of data, in the
%   form of a series of buffers passed into it on successive calls, to a MATLAB
%   array of any type. The converted output may be returned incrementally on
%   each call, which the caller should concatenate to form the result, or the
%   result may not be available until the stream has ended.
%
%   The converter maintains internal state about the conversion that is needed
%   if buffers are split across information units that could result in useful
%   output. For example, when converting a uint8 stream from native to Unicode,
%   if a buffer ends inside a character boundary, the returned value for each
%   buffer would be the decoded characters that are complete, and the internal state
%   might contain a partial character that was at the end of that buffer.
%
%   A streaming JSON decoder might not return any result until the entire stream
%   is read, or it may return a MATLAB array to which it appends new data as the
%   stream is converted.
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/http. Its behavior
%   may change, or the function itself may be removed in a future release.

% Copyright 2017 The MathWorks, Inc.
    methods (Abstract)
        % convert Convert a buffer of data and return result
        %   [RES, CONVERTER] = convert(CONVERTER, DATA) processes DATA, a buffer of data
        %   from an input stream that may be any type, and returns RES, any type of
        %   data, plus a possibly modified copy of itself containing internal state. The
        %   caller is expected to concatenate RES to any previous result using some custom
        %   append function (typically, equivalent to horzcat), or just use RES as the
        %   next increment of results.
        %
        %   It is the expectation that the concatenated RES values always provide useful
        %   data, should the data stream end and no more DATA buffers are available.
        %   This method may return an empty RES if there was insufficient information in
        %   DATA to return a useful result on any particular call. The expectation is
        %   that a subsequent call will return a result, assuming that DATA is valid for
        %   the conversion being done.
        %   
        %   If DATA is empty, this indicates EOF on the input stream. This function
        %   should return any final result in RES and then reset itself to process a new
        %   stream. It may throw an exception if if cannot fully convert all the data
        %   it has been given.
        %
        %   If called a subsequent time with empty DATA, this function should return its
        %   previous result if any.
        [res, obj] = convert(obj, data)
        
        % reset Reset this converter for a new stream
        obj = reset(obj)
    
    end
end
    
        
        