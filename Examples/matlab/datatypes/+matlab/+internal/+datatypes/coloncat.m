function x = coloncat(istart,iend)
%COLONCAT Create and concatenate multiple colon expressions into one vector
%   X = COLONCAT(ISTART,IEND) returns a vector containing the values defined
%   by each of the colon expressions ISTART(I):IEND(I). In other words,
%   X = [ISTART(1):IEND(1) ISTART(2):IEND(2) ... ISTART(END):IEND(END)].
%   ISTART and IEND equal-length vectors of integers.  If ISTART(I) > IEND(I),
%   the corresponding colon expression is empty and contributes nothing to X.

%   Copyright 2012 The MathWorks, Inc.

len = iend - istart + 1;

% Ignore empty sequences
pos = (len > 0);
istart = istart(pos);
iend = iend(pos);
len = len(pos);
if isempty(len)
    x = [];
    return;
end

% Expand out the colon expressions
endlocs = cumsum(len);
incr = ones(1,endlocs(end));
jump = istart(2:end) - iend(1:end-1);
incr(endlocs(1:end-1)+1) = jump;
incr(1) = istart(1);
x = cumsum(incr);
