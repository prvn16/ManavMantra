function out = applyiccsequence(in,sequence)
%APPLYICCSEQUENCE Evaluate data through a sequence of ICC cforms.
%   OUT = APPLYICCSEQUENCE(IN, SEQUENCE) processes the data
%   in IN through the cforms in SEQUENCE, storing the results
%   in OUT.
%
%   See also MAKECFORM, APPLYCFORM.

%   Copyright 1993-2004 The MathWorks, Inc.
%   Original authors:  Scott Gregory, Toshia McCabe 11/04/02
 
cform_names = fieldnames(sequence);
num_cforms = length(cform_names);

% Apply cform(s) in sequence
for k = 1:num_cforms
    out = applycform(in, sequence.(cform_names{k}));
    in = out;
end
