function h = blkdgmnode(varargin)
% BLKDGMNODE constructor
%

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

bd = [];
h = fxptui.blkdgmnode;
if nargin > 0
	bd = get_param(varargin{1}, 'Object');	
end
if(isempty(bd)); return; end
h = fxptui.createsubsys(bd);
h.initNode;
h.populate;
h.firehierarchychanged;



% [EOF]

