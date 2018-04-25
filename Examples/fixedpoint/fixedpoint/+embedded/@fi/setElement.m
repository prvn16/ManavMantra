function setElement(x,val,varargin)
%SETELEMENT Internal use only: set an individual indexed element of x to a given value (val)
%   setElement(x, val, index1, index2, ... , indexN) sets an individual
%   indexed element of x at the position specified by the set of indices
%   (index1, index2, .. indexN), to the value specified by 'val'. 'val' may
%   be a fi object or a double.  
%   This function helps to bypass the indexing issue with Fi objects 
%   (see record ID 549571).
%
%   Example:
%   For an example, see getElement.
%
%   See also EMBEDDED.FI/GETELEMENT

%   Copyright 2009-2015 The MathWorks, Inc.
%     

narginchk(3,inf);
if ~isscalar(val)
    error(message('fixed:fi:indexNotScalar'));
end
overall_idx = elementGetSetChecksAndSingleIndex(x, varargin{:});
x.set_element(overall_idx,val);
