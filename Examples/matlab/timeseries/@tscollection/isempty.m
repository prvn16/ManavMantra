function boo = isempty(this)
%ISEMPTY  Evaluate to TRUE for empty tscollection object.
%
%   ISEMPTY(TSC) returns 1 (TRUE) when the tscollection object contains no
%   samples, and otherwise 0 (FALSE).
%
%   See also SIZE and LENGTH methods
 
%   Copyright 2005-2007 The MathWorks, Inc.

boo = (this.TimeInfo.length==0);


