function tbxStruct=demos
% DEMOS Show examples in the Help browser.
%
% See also DEMO.

% Copyright 1984-2012 The MathWorks, Inc.

if nargout==0
    % An alias for DEMO with no options.
    demo;
else
    % Return an empty to FINDDEMO.
    tbxStruct=[];
end
