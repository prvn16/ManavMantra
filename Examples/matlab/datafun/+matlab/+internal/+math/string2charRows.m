function C = string2charRows(S)
%string2charRows Convert N-D string array to N-D array of char rows
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%
% Convert string to char array. Convert <missing> string to blank rows ' '.
% Used for inputs with size(S,2) equal to 1.

%   Copyright 2016 The MathWorks, Inc.

S(ismissing(S)) = ' ';
C = char(S);
if ~ismatrix(S)
    % string.char converts an m-by-1-by-p ND string aray to
    % m-by-n-by-1-by-p ND char array. We need an m-by-n-by-p ND char array.
    sizeC = size(C); % sizeC(3) is 1
    sizeC(3) = [];   % squeeze out sizeC(3)
    C = reshape(C,sizeC);
end