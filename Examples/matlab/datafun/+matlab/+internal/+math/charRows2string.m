function S = charRows2string(C)
%charRows2string Convert N-D array of char rows to N-D string array
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%
% Convert char array to string. Convert blank rows ' ' to <missing> string.
% size(S,2) is 1.

%   Copyright 2016 The MathWorks, Inc.

if ismatrix(C)
    S = string(C);
else
    % We cannot use string because it converts an m-by-n-by-p ND char array
    % into m-by-p string array. We need an m-by-1-by-p string array.
    sizeS = size(C);
    sizeS(2) = 1;
    S = reshape(string(C),sizeS);
end
blankRow = string(repmat(' ',1,size(C,2)));
S(S == blankRow) = string(NaN);