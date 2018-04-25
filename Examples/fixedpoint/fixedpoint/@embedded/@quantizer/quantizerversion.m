function v = quantizerversion(q)
%QUANTIZERVERSION Quantizer object version number
%
%   V = QUANTIZERVERSION  returns the quantizer object's version number.

%   Thomas A. Bryan
%   Copyright 1999-2004 The MathWorks, Inc.

% Version history.
%
% Version 1 = R12, MATLAB OOPS with Java.
%
%  Default R12 structure:
%  struct(quantizer)
%              mode: 'fixed'
%         roundmode: 'floor'
%      overflowmode: 'saturate'
%            format: [16 15]
%         quantizer: [1x1 com.mathworks.toolbox.filterdesign.Sfixfloorsaturate]
%           version: 1
%
%===============================================================================
% Version 2 = R12.2, UDD version with C++.
%
%  struct(quantizer)
% 
%               mode: 'fixed'
%          roundmode: 'floor'
%       overflowmode: 'saturate'
%             format: [16 15]
%         wordlength: 16
%     fractionlength: 15
%     exponentlength: 0
%                max: -1.7977e+308
%                min: 1.7977e+308
%         noverflows: 0
%        nunderflows: 0
%        noperations: 0
%        denormalmax: 3.0518e-05
%        denormalmin: 3.0518e-05
%                eps: 3.0518e-05
%       exponentbias: 0
%        exponentmax: 0
%        exponentmin: 0
%            realmax: 1.0000
%            realmin: 3.0518e-05
%            version: 2

v = 2;
