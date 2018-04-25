%SUPPORT Open MathWorks Technical Support Web Page.
%   SUPPORT, with no inputs, opens your web browser to The MathWorks
%   Technical Support Web Page at http://www.mathworks.com/support.
%
%   On this page, you will find links to
%     - a Solution Search Engine
%     - a "virtual Technical Support Engineer" that, through a
%       series of questions, determines possible solutions to the
%       problems you are experiencing
%     - Technical Notes
%     - Tutorials
%     - Bug fixes and patches
%
%   SUPPORT will be removed in a future release. 
%
%   See also WEB.

%   Rob Monteiro, 12-16-98
%   Copyright 1984-2011 The MathWorks, Inc. 

warning(message('MATLAB:support:FunctionToBeRemoved'))

disp(getString(message('MATLAB:support:disp_OpeningTheTechnicalSupportWebPage')))
disp(' ')

web('http://www.mathworks.com/support', '-browser');
