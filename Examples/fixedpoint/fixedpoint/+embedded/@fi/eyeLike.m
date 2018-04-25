function y = eyeLike(prototype, varargin) %#codegen
% eyeLike  Identity array with prototype's class and attributes.
%
%   eyeLike(PROTOTYPE, M, N) is is an M-by-N identity array
%   PROTOTYPE's class and attributes.  eyeLike is a helper
%   function for builtin EYE. 
%
%   See also EYE.
        
%   Copyright 2014 The MathWorks, Inc.
    if ~isfi(prototype)
        error(message('fixed:fi:firstInputNotFi'));
    end
    % Saturate the 1's so they never wrap to negative values
    F = prototype.fimath;
    Fsat = fimath(F,'OverflowAction','Saturate');
    y = castLike(setfimath(prototype,Fsat), eye(varargin{:}));
    if isfimathlocal(prototype)
        y = setfimath(y,F);
    else
        y = removefimath(y);
    end
end

