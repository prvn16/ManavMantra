function err = javachk(requiredLevel, component)
%JAVACHK Validate level of Java support.
%   MSG = JAVACHK(LEVEL) returns a generic error message if
%   the required level of Java support is not available.  If it
%   is, it returns an empty matrix.  The following levels of support
%   exist:
%
%   LEVEL      MEANING
%   -----------------------------------------------------
%   'jvm'      The Java Virtual Machine is running.
%   'awt'      AWT components are available.
%   'swing'    Swing components are available.
%   'desktop'  The MATLAB interactive desktop is running.
%
%   MSG = JAVACHK(LEVEL, COMPONENT) returns an error message structure that 
%   names the affected COMPONENT if the required level of Java support 
%   is not available.  If it is, it returns an empty structure.  See example
%   below.
%
%   EXAMPLE:
%   If you want to write an m-file that displays a Java Frame and want
%   it to error gracefully if a Frame cannot be displayed, you can do 
%   the following:
%   
%   error(javachk('awt','myFile'));
%   myFrame = java.awt.Frame;
%   myFrame.setVisible(1);
%
%   If a Frame cannot be displayed, the error will read:
%   ??? myFile is not supported on this platform.
%
%   See also USEJAVA, ERROR.

%   Copyright 1984-2010 The MathWorks, Inc.

% Check for valid argument list
if nargin < 1 || nargin > 2
    narginchk(1,2);
end

% If we're running at an insufficient level, report it.  If no
% component name was supplied, make up a generic one.
if ~usejava(requiredLevel)
    switch requiredLevel
        case 'jvm'
            reason = getString(message('MATLAB:javachk:FeatureIsNotCurrentlyAvailable','Java'));
        case 'awt'
            reason = javaReason(getString(message('MATLAB:javachk:FeatureIsNotCurrentlyAvailable','AWT')));
        case 'swing'
            reason = javaReason(getString(message('MATLAB:javachk:FeatureIsNotCurrentlyAvailable','Swing')));
        case 'mwt'
            reason = javaReason(getString(message('MATLAB:javachk:NoDisplayIsAvailable')));
        case 'desktop'
            reason = javaReason(getString(message('MATLAB:javachk:DesktopIsNotCurrentlyAvailable')));
        otherwise
            reason = javaReason(getString(message('MATLAB:javachk:FeatureIsNotCurrentlyAvailable',requiredLevel)));
    end
    if nargin == 1
        err.message = getString(message('MATLAB:javachk:thisFeatureNotAvailable',reason));
        err.identifier = 'MATLAB:javachk:thisFeatureNotAvailable';
    else
        err.message =  getString(message('MATLAB:javachk:featureNotAvailable', ...
                              component, reason));
        err.identifier = 'MATLAB:javachk:featureNotAvailable';
    end
else
    err.message = '';
    err.identifier = '';
    err = err(zeros(0,1));
end

function reason = javaReason(msg)
    if ~usejava('jvm') 
        reason = getString(message('MATLAB:javachk:FeatureIsNotCurrentlyAvailable','Java'));
    else
        reason = msg;
    end
