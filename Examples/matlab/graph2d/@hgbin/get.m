function val = get(aBin, varargin)
%HGBIN/GET Get hgbin property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

if nargin == 2
   switch lower(varargin{1})
   case 'items'
      val = aBin.Items;
      return;
   end
end

if nargin > 1
   val = get(aBin.scribehgobj, varargin{:});
else
   val = get(aBin.scribehgobj);
end
