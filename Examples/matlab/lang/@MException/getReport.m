%getReport Get error message for exception.
%   REPORT = getReport(ME) returns a character vector formatted message
%   based on the MException, ME. The message returned by getReport is the
%   same as the error message displayed by MATLAB when it throws the
%   exception.
%
%   REPORT = getReport(ME, TYPE) where TYPE is the type of report desired.
%   'basic' and 'extended' are the allowed types. 'extended' is the default
%   option which provides a formatted error message, a stack and causes
%   summary. The 'basic' report type returns a character vector with a
%   formatted error message only, without the stack and causes.
%
%   REPORT = getReport(ME, TYPE, 'hyperlinks', VALUE)
%       Where VALUE can be one of: 
%           'off'        --  ensures no hyperlinks are added to the report
%           'on'         --  adds hyperlinks to the report
%           'default'    --  specifies that the default for the command
%                            window is used to determine if hyperlinks are
%                            added to the report.
%   Example:
%      try
%         surf
%      catch ME
%         report = getReport(ME)
%      end
%
%   See also MException, MESSAGE, ERROR, ASSERT, TRY, CATCH.

%   Copyright 2007-2017 The MathWorks, Inc.
%   Built-in function.
