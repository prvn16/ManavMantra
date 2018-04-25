%addCause Record additional causes of exception.
%   NEW_ME = addCause(BASE_ME, CAUSE_ME) creates a new MException
%   object NEW_ME from two existing MException objects, BASE_ME and
%   CAUSE_ME. addCause constructs NEW_ME by making a copy of the BASE_ME
%   object and appending CAUSE_ME to the CAUSE property of that object.
%
%   All objects of the MException class have a property called CAUSE which
%   is defined as a vector of additional MException objects that can be
%   added onto a base object of that class. The purpose of the CAUSE 
%   property is to hold additional exception records that might point out 
%   the cause of the base exception.
%
%   BASE_ME = addCause(BASE_ME, CAUSE_ME) modifies existing MException 
%   object BASE_ME by appending CAUSE_ME to the CAUSE property of that 
%   object.
%
%   Example:
%      try
%         x = D(1:25);
%      catch cause1_ME
%         try
%            filename = 'test204';
%            testdata = load(filename);
%            x = testdata.D(1:25)
%         catch cause2_ME
%            base_ME = MException('MATLAB:LoadErr', ...
%                'Unable to load from file %s', filename);
%            new_ME = addCause(base_ME, cause1_ME);
%            new_ME = addCause(new_ME, cause2_ME);
%            throw(new_ME);
%         end
%      end
%
%   See also MException, CAUSE, ERROR, ASSERT, TRY, CATCH.

%   Copyright 2007-2010 The MathWorks, Inc.
%   Built-in function.
