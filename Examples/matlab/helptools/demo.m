function demo(action,categoryArg) 
% DEMO Access examples via Help browser. 
%
%   DEMO displays a list of featured MATLAB� and Simulink� examples in the 
%   Help browser.
%
%   DEMO TYPE NAME displays the examples for the product matching NAME and
%   TYPE, as defined in that product's info.xml or demos.xml file.
%   
%   Examples:
%       demo 'matlab'
%       demo 'toolbox' 'signal'
%
%   See also DOC.

%   Copyright 1984-2012 The MathWorks, Inc.

error(javachk('mwt',mfilename))
if nargin < 1
    com.mathworks.mlservices.MLHelpServices.showDemos;
elseif nargin == 1
    action = char(action);
    com.mathworks.mlservices.MLHelpServices.showDemos(action);
elseif nargin == 2
    action = char(action);
    categoryArg = char(categoryArg);
    com.mathworks.mlservices.MLHelpServices.showDemos(action, categoryArg);
end
