function T = eml_sim2fi_getNType(varargin)
%---------------------------------------------------------------
%
% Determine the specified data type

% Copyright 2013 The MathWorks, Inc.


narginchk(1,5);

% the robust mode is not supported in code gen    
if ischar( varargin{end} ) && strncmpi('robust',varargin{end},6)
    if isempty(coder.target)
        error(message('fixed:coder:invalidInputArg'));
    else
        eml_invariant(false, eml_message('fixed:coder:invalidInputArg'));
    end
end

switch nargin
  case 3
    % A = SIM2FI(IntArray, Signed, WordLength, FractionLength)
    T = numerictype('Signed', varargin{1}, 'WordLength', varargin{2},...
                    'FractionLength', varargin{3});
    %T.DataType        = 'fixed';
    %T.Scaling         = 'BinaryPoint';
    %T.Signed          = varargin{1};
    %T.WordLength      = varargin{2};
    %T.FractionLength  = varargin{3};
    
  otherwise    % case {1, 2, 4, 5} not supported in code gen
    if isempty(coder.target)
         error(message('fixed:coder:incorrectNumberOfInputs'));
    else
        eml_invariant(false, eml_message('fixed:coder:incorrectNumberOfInputs'));
    end
end

if T.WordLength > 128
    if isempty(coder.target)
        error(message('fixed:sim2fi:invalidSLFixPtWordLength'));
    else
        eml_invariant(false, eml_message('fixed:sim2fi:invalidSLFixPtWordLength'));
    end
        
end
