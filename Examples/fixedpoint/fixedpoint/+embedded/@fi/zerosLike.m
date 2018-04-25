function y = zerosLike(prototype, varargin) %#codegen
% zerosLike  Zeros array with prototype's class and attributes.
%
%   zerosLike(PROTOTYPE, M, N, P, ...) is is an M-by-N-by-P-by-... array of
%   zeros with PROTOTYPE's class and attributes.  zerosLike is a helper
%   function for builtin ZEROS. 
%
%   See also ZEROS.
        
%   Copyright 2012 The MathWorks, Inc.
    if ~isfi(prototype)
        error(message('fixed:fi:firstInputNotFi'));
    end
    y = castLike(prototype, zeros(varargin{:}));
end

