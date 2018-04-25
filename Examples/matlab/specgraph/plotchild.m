function ch = plotchild(ax, dim, bfmode)
%PLOTCHILD Get plot objects in an axis
%  This function is a helper function for the plot tools and basic
%  fitting. Do not call this function directly.

%   CH = PLOTCHILD(AX) returns the list of plot object
%   children of axes AX. This function is a helper function for the
%   plot tools.
%
%   CH = PLOTCHILD(AX,DIM) for DIM=2 or 3 returns the 2D or 3D
%   children of axes AX, respectively.
%
%   CH = PLOTCHILD(AX,2,true) returns children that are compatible with
%   the basic fitting GUI. 
%
%   See also: PLOTTOOLS

%   Copyright 1984-2016 The MathWorks, Inc.

if nargin < 2
  dim = 3;
end
if nargin < 3
  bfmode = false;
end
ch = findobj(ax,'-depth',1,'-regexp','Type','[^.*axes]');
if iscell(ch)
    ch = ch(~cellfun(@(x) isempty(x),ch));
    % Convert ch into an array
    if ~isempty(ch) % ch may be empty for arrays of axes with no children       
        chtemp = ch;        
        ch = chtemp{1};
        for k=2:length(chtemp)
            ch = [ch; chtemp{k}]; %#ok<AGROW>
        end
    end
end
if ~isempty(ch)
    ok = false(1,length(ch));
    for k=1:length(ch)
        ok(k) = isplotchild(ch(k), dim, bfmode);
    end
    ch = ch(ok);
end
