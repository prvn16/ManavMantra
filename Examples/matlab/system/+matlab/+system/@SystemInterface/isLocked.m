%ISLOCKED Locked status for input attributes and non-tunable properties
%   L = isLocked(OBJ) returns a logical value, L, which indicates whether
%   input attributes and non-tunable properties are locked for the System
%   object, OBJ. The object performs an internal initialization the first 
%   time the step method is executed. This initialization locks non-tunable 
%   properties and input specifications, such as dimensions, complexity,
%   and data type of the input data. After OBJ is locked, the isLocked method 
%   returns a true value.
%
%   See also step, release.

%   Copyright 2009-2012 The MathWorks, Inc.

% [EOF]
