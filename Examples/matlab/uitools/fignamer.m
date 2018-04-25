function name = fignamer(str)
% This function is undocumented and will change in a future release

%FIGNAMER Chooses next available figure name.
%   NAME = FIGNAMER(STR) returns the next available figure name starting with STR.
%   Note that it even checks figures with HiddenHandles.
%
%   Example:
%       hfig1 = figure('name','example1') ;
%       hfig2 = figure('name','example2','handlevis','off') ;
%       this_name = fignamer('example') 
%
%   See also FIGURE

%   Author(s): A. Potvin, 11-1-94
%   Copyright 1984-2008 The MathWorks, Inc.

figs=allchild(0);
i = 1;
name = [str int2str(i)];
while ~isempty(findobj(figs,'flat','Name',name))
   i = i +1;
   name = [str int2str(i)];
end

% end fignamer
