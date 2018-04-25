function f = fimath2use(varargin)
%FIMATH2USE Determine which FIMATH to use.
%   This should be a private method.


%   Copyright 2009-2012 The MathWorks, Inc.
%     

b = cellfun(@isfimathlocal,varargin);

if ~any(b),
    f = fimath;
else
    idx = find(b,1,'first');
    f = varargin{idx}.fimath;        
    inputsWithFiMath = varargin(b);
    
    for k = 1:length(inputsWithFiMath),
        if ~isequal(inputsWithFiMath{k}.fimath,f)
            error(message('fixed:fi:localFimathMismatch'));
        end
    end
end
