function unlock(fig)
%UNLOCK Unlock a figure that has been locked by the App Testing Framework
%
%   matlab.uitest.unlock(FIG) restores the figure FIG to its "unlocked"
%   state so that users may interact with its components. FIG is an array
%   of figure handles. Each figure handle must be a handle to a figure
%   created with the UIFIGURE function.
%
%   Example:
%
%     % Create a class-based MATLAB unit test that derives from
%     % matlab.uitest.TestCase and contains a KEYBOARD statement:
%     classdef SimpleUITest < matlab.uitest.TestCase
%         methods (Test)
%             function testContainingKeyboardCall(testCase)
%                 fig = uifigure;
%                 testCase.addTeardown(@delete, fig);
%                 button = uibutton(fig);
%                 keyboard; % for demonstration purposes
%             end
%         end
%     end
%
%     % Run the test and enter debug mode at the KEYBOARD command. Notice
%     % that the button is not able to be pressed interactively while the
%     % figure is locked.
%     >> runtests SimpleUITest
%
%     % While in context of the "fig" variable, unlock the figure. The
%     % button is now able to be pressed interactively. Resuming execution
%     % of the test will close the figure at teardown.
%     K>> matlab.uitest.unlock(fig);
%
% See also matlab.uitest.TestCase, uifigure.

% Copyright 2016-2017 The MathWorks, Inc.

import matlab.ui.internal.Driver;

narginchk(1,1);

driver = Driver;
driver.unlock(fig);
end