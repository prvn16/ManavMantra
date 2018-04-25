function y = onesLike(prototype, varargin) %#codegen
% onesLike  Ones array with prototype's class and attributes.
%
%   onesLike(PROTOTYPE, M, N, P, ...) is is an M-by-N-by-P-by-... array of
%   ones with PROTOTYPE's class and attributes.  onesLike is a helper
%   function for builtin ONES. 
%
%   See also ONES.
        
%   Copyright 2012-2014 The MathWorks, Inc.
    if ~isfi(prototype)
        error(message('fixed:fi:firstInputNotFi'));
    end
    % Saturate the 1's so they never wrap to negative values
    F = prototype.fimath;
    Fsat = fimath(F,'OverflowAction','Saturate');
    y = castLike(setfimath(prototype,Fsat), ones(varargin{:}));
    if isfimathlocal(prototype)
        y = setfimath(y,F);
    else
        y = removefimath(y);
    end

end

