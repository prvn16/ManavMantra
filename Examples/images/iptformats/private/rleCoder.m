function scanline = rleCoder(data, dataLength)
%rleCoder   Compress data using HDR adaptive run-length encoding.

% Unlike the description in Graphics Gems II.8 (p.89), code values greater
% than 128 correspond to repeated runs, while smaller code values are
% literal dumps. See the following web site for more details: 
% <http://www.andrew.cmu.edu/user/yihuang/radiance_pic/rgbe.html#syntax>.
% The adaptive RLE used by HDR also does not shift code values by one.
% There can be only 127 elements in a run.

% Copyright 2007-2017 The MathWorks, Inc.

scanline = rleCoder_mex(uint8(data), dataLength);

% Crop the scanline to exclude the unused buffer.
scanline(isnan(scanline)) = [];