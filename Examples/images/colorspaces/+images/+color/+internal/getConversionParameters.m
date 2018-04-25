function p = getConversionParameters(steps)
% getConversionParameters Get parameters associated with color conversion steps
%
%    p = getConversionParameters(steps)
%
%    p = getConversionParameters(converter)
%
%    p = getConversionParameters(fh)
%
%    p = getConversionParameters(steps) returns the parameters associated with each element of the
%    cell array steps. In other words, p{k} contains the parameters associated with steps{k}.
%
%    p = getConversionParameters(converter) is the same as p =
%    getConversionParameters(converter.ConversionSteps).
%
%    p = getConversionParameters(fh) returns a struct containing any workspace variables associated
%    with the function handle fh.
%   

%    Copyright 2014 The MathWorks, Inc.

if iscell(steps)
    p = cell(1, numel(steps));
    for k = 1:numel(steps)
        p{k} = images.color.internal.getConversionParameters(steps{k});
    end
elseif isa(steps, 'images.color.ColorConverter')
    p = images.color.internal.getConversionParameters(steps.ConversionSteps);
else
    ff = functions(steps);
    if isfield(ff,'workspace')
        w = ff.workspace{1};
        if isempty(fieldnames(w))
            p = struct;
        else
            p = ff.workspace{1};
        end
    else
        p = struct;
    end
end
end
