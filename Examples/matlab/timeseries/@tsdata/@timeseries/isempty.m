function boo = isempty(this)
%ISEMPTY  Evaluate to TRUE for empty time series objects
%
%   ISEMPTY(TS) returns 1 (TRUE) when the time series object contains no
%   samples, and otherwise 0 (FALSE).
%
%   See also SIZE and LENGTH methods.

%   Copyright 2005-2010 The MathWorks, Inc.

boo = (isempty(this.Tsvalue) || this.Tsvalue.Length==0);


