function [num_comp_in, num_comp_out] = checkSequence(sequence)
% checkSequence Checks color converter sequence for consistency
%
%    [num_comp_in,num_comp_out] = images.color.internal.checkSequence(sequence)
%
%    Checks the cell array containing color converters for consistency in the number of input and
%    output color components. Returns the overall number of input and output components for the
%    entire sequence.
%

%    Copyright 2014 The MathWorks, Inc.

for k = 1:numel(sequence)
    if ~isa(sequence{k}, 'images.color.ColorConverter')
        throwAsCaller(MException(message('images:color:badTypeInSequence')));
    end
end

% Form a P-by-2 matrix, where P is the number of converters in the sequence. Each row of the matrix
% contains the number of input and output components for the corresponding converter. Replace 'any'
% with the flag value (-1).
numcomps = zeros(numel(sequence), 2);
any_flag = -1;
for k = 1:numel(sequence)
    if isequal(sequence{k}.NumInputComponents, 'any')
        numcomps(k, 1) = any_flag;
        numcomps(k, 2) = any_flag;
    else
        numcomps(k, 1) = sequence{k}.NumInputComponents;
        numcomps(k, 2) = sequence{k}.NumOutputComponents;
    end
end

% Remove 'any' transforms from the sequence.
any_transform_mask = all(numcomps == any_flag, 2);
numcomps(any_transform_mask, :) = [];

% Check validity of sequence.
for k = 2:size(numcomps, 1)
    if numcomps(k-1, 2) ~= numcomps(k, 1)
        throwAsCaller(MException(message('images:color:numComponentsMismatch')));
    end
end

if isempty(numcomps)
    % All of the converters in the input sequence can handle any number of input and output color
    % components. Therefore, the sequence as a whole can handle any number as well.
    num_comp_in = 'any';
    num_comp_out = 'any';
else
    num_comp_in = numcomps(1, 1);
    num_comp_out = numcomps(end, 2);
end

end
