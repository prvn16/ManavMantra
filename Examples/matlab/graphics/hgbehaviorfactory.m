function [b] = hgbehaviorfactory(behavior_name,hObj)
% This internal helper function may be removed in a future release.

%HGBEHAVIORFACTORY Convenience for creating behavior objects
%   
%   HGGETBEHAVIOR
%   With no arguments, a list of all registered behavior
%   objects is generated to the command window.
%
%   BH = HGBEHAVIORFACTORY(NAME)
%   Specify NAME (string or cell array of strings) to create
%   behavior objects.
%
%   Example 1:
%   bh = hgbehaviorfactory('Zoom');
%
%   Example 2:
%   h = line;
%   bh = hgbehaviorfactory({'Zoom','DataCursor','Rotate3d'});
%   h.Behavior = bh;
%
%   See also hgaddbehavior, hggetbehavior.

% Copyright 2003-2017 The MathWorks, Inc.

if nargin==0
    % Pretty print output
    info = localGetBehaviorInfo;
    localPrettyPrint(info);
else
    % if the axes is passed as the second argument, behavior object is
    % constructed based on the axes or figure version.
    if nargin == 1 
        hObj = [];
    end
    b = localCreate(behavior_name, hObj);
end

%---------------------------------------------------%
function [ret_h] = localCreate(behavior_name, hObj)

ret_h = [];
dat = localGetBehaviorInfo(hObj);
% Note that ret_h cannot be used to accumulate both MCOS and UDD behavior
% objects. This should not happen currently since hgbehaviorfacotry is not
% called with a cell array of behavior_name. 
for n = 1:length(dat)
     info = dat{n};
     s = strcmpi(behavior_name,info.name);
     if any(s)
         behavior_name(s) = [];
         bh = feval(info.constructor);
         if isempty(ret_h)
             ret_h = bh;
         else
             ret_h(end+1) = bh; %#ok<AGROW>
         end
     end
end

%---------------------------------------------------%
function localPrettyPrint(behaviorinfo)
% Pretty prints to command window
% in a similar manner as the PATH command.

% Header
disp(' ');
fprintf('\tBehavior Object Name         Target Handle\n')    
fprintf('\t--------------------------------------------\n')

info = {};
for n = 1:length(behaviorinfo)
    str1 = behaviorinfo{n}.name;
    str2 = behaviorinfo{n}.targetdescription;

    % string formatting, padding specific number of dots
    padl = 30-length(str1);
    p = [];
    if padl>0
      p = zeros(1,padl); p(:) = '.';
    end
    info{n} = ['''',str1,'''',p,str2];
end

% Display items
ch= strvcat(info);
tabspace = ones(size(ch,1),1);
tabspace(:) = sprintf('\t');
s = [tabspace,ch];
disp(s)

% Footer
fprintf(newline)

%---------------------------------------------------%
function [behaviorinfo] = localGetBehaviorInfo(~)
% Loads info for registered behavior objects

behaviorinfo = {};
if nargin == 0 
    hObj = [];
end

info = [];
info.name = 'Plotedit';
info.targetdescription = 'Any Graphics Object';
info.constructor = 'matlab.graphics.internal.PlotEditBehavior';

behaviorinfo{end+1} = info;

info = [];
info.name = 'Print';
info.targetdescription = 'Figure and Axes';
info.constructor = 'matlab.graphics.internal.PrintBehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'Zoom';
info.targetdescription = 'Axes';
info.constructor = 'matlab.graphics.internal.ZoomBehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'Pan';
info.targetdescription = 'Axes';
info.constructor = 'matlab.graphics.internal.PanBehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'Rotate3d';
info.targetdescription = 'Axes';
info.constructor = 'matlab.graphics.internal.Rotate3dBehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'DataCursor';
info.targetdescription = 'Axes and Axes Children';
info.constructor = 'matlab.graphics.internal.DataCursorBehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'MCodeGeneration';
info.targetdescription = 'Axes and Axes Children';
info.constructor = 'matlab.graphics.internal.MCodeGenBehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'LiveEditorCodeGeneration';
info.targetdescription = 'Any graphics object';
info.constructor = 'matlab.graphics.internal.LiveEditorCodeGenBehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'DataDescriptor';
info.targetdescription = 'Axes and Axes Children';
info.constructor = 'matlab.graphics.internal.DataDescriptorBehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'PlotTools';
info.targetdescription = 'Any graphics object';
info.constructor = 'matlab.graphics.internal.plottools.PlottoolsBehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'Linked';
info.targetdescription = 'Any graphics object';
info.constructor = 'matlab.graphics.internal.datamanager.LinkBehavior';
behaviorinfo{end+1} = info;

info = [];
info.name = 'Brush';
info.targetdescription = 'Any graphics object';
info.constructor = 'matlab.graphics.internal.datamanager.BrushBehavior';
behaviorinfo{end+1} = info;
