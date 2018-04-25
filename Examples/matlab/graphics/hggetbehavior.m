function [ret_h] = hggetbehavior(h,behavior_name,flag)
% This internal helper function may be removed in a future release.

%HGGETBEHAVIOR Convenience for getting behavior objects
%
%   HGGETBEHAVIOR 
%   With no arguments, a list of all registered behavior
%   objects is generated to the command window.
%
%   BH = HGGETBEHAVIOR(H)
%   Identical to get(H,'Behavior'), this syntax returns all 
%   behavior objects currently associated with handle H.
%
%   BH = HGGETBEHAVIOR(H,NAME) 
%   This syntax will return a behavior object of the given
%   NAME (NAME can be a string or cell array of strings). 
%   Behavior objects are lazy loaded (created on the fly) 
%   by this function. 
%
%   BH = HGGETBEHAVIOR(H,NAME,'-peek') 
%   The '-peek' flag by-passes lazy loading so that no behavior
%   objects are implicitly created. This syntax may return 
%   empty output if no behavior objects of the given type
%   are currently associted with this object.
%
%   Example 1:
%   % Prevent zooming on axes
%   ax = axes;
%   bh = hggetbehavior(ax,'Zoom');
%   bh.Enable = false; 
%   zoom on; % zoom should not work on this axes
%
%
%   Example 2: (place in MATLAB file)
%   % Customize data cursor string function for a line
%   h = line;
%   bh = hggetbehavior(h,'DataCursor');
%   bh.UpdateFcn = @myupdatefcn; 
%   
%   function [str] = myupdatefcn(hSource,hEvent)
%   % See DATACURSORMODE for full description of
%   % input arguments.
%   str = 'my string';
%
%   See also hgbehaviorfactory.

% Copyright 2003-2017 The MathWorks, Inc.


if nargin==0
    % pretty print list of available behavior objects
    hgbehaviorfactory
    return;
end

ret_h = [];
h = handle(h);

if length(h)>1
  error(message('MATLAB:hggetbehavior:ScalarHandleRequired'));
end

if nargin==1
    ret_h = get(h,'Behavior');
elseif nargin==3
    behavior_name = lower(behavior_name);
    if strcmp(flag,'-peek')
        ret_h = localPeek(h,behavior_name);     
    end
elseif nargin==2
    behavior_name = lower(behavior_name);
    ret_h = localGet(h,behavior_name);
end

%-------------------------------------------%
function [ret_h] = localGet(h,behavior_name)
% ToDo: Optimize to avoid excessive looping

bb = get(h,'Behavior');
ret_h = [];

if ischar(behavior_name)
    behavior_name = {behavior_name};
end

% Note that ret_h cannot be used to accumulate both MCOS and UDD behavior
% objects. This should not happen currently since hggetbehavior is not
% called with a cell array of behavior_names. 
for n = 1:length(behavior_name)
     bn = behavior_name{n};
     b = localPeek(h,bn);
     if isempty(b)
        b = hgbehaviorfactory(bn,h);
        if ~isempty(b) 
            if ~dosupport(b,h)
                error(message('MATLAB:hggetbehavior:UnsupportedHandle'))  
            end
            bb(1).(behavior_name{n}) = b;
            set(h,'Behavior',bb);
            if isempty(ret_h)
                ret_h = b;
            else
                ret_h(end+1) = b; %#ok<AGROW>
            end
        end
     else
        if isempty(ret_h)
            ret_h = b;
        else
            ret_h(end+1) = b; %#ok<AGROW>
        end
     end
end

%-------------------------------------------%
function [ret_h] = localPeek(h,behavior_name)
% Loop through available behavior objects

ret_h = handle([]);
if isprop(handle(h),'Behavior')
    bb = get(h,'Behavior');
else
    return
end
if isfield(bb,behavior_name)
    ret_h = bb(1).(behavior_name);
end
