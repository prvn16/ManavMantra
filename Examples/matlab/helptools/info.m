function info(arg)
%INFO   Information about MathWorks.
%   INFO displays information about MathWorks in the Command Window.
%
%   INFO will be removed in a future release. Use DOC instead. 
%
%   See also WHATSNEW.

%   Copyright 1984-2011 The MathWorks, Inc.

warning(message('MATLAB:info:FunctionToBeRemoved'))

disp(' ')
disp(getString(message('MATLAB:info:ForInfoAboutMathWorks')))
if matlab.internal.display.isHot 
    disp('<a href="matlab:web(''http://www.mathworks.com/company/aboutus/contact_us'',''-browser'')">http://www.mathworks.com/company/aboutus/contact_us</a>')
else
    disp('http://www.mathworks.com/company/aboutus/contact_us')
end
disp(getString(message('MATLAB:info:MathWorksPhone')))
disp(' ')
