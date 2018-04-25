function out = applycformsequence(in, cforms)
%APPLYCFORMSEQUENCE Apply a sequence of cforms.
%   OUT = APPLYCFORMSEQUENCE(IN, CFORMS) applys a sequence of cforms to
%   the input data, IN.  CFORMS is a cell array containing the cform
%   structs.

%   Copyright 1993-2003 The MathWorks, Inc.

out = in;
for k = 1:length(cforms)
    out = applycform(out, cforms{k});
end
