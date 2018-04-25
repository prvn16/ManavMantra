function h = hgloadStructClass(S)
%hgloadStructClass Convert a structure to object handles.
%
%  hgloadStructClass converts a saved structure into a set of new handles.
%  This function is called when MATLAB is using objects as HG handles.

%   Copyright 2009-2015 The MathWorks, Inc.

% Create parent-less objects
h = struct2handle(S, 'none', 'convert');

% "In comments below, "new" refers to the MATLAB graphics system introduced
% in Release 2014b. "old" refers to graphics system used prior to Release
% 2014b.

% "old" -> "new" restore the linkaxes 
allAxes = findall(h,'Type','axes');                                           
targets = cell(1,length(allAxes));
props = cell(1,length(allAxes));
maxGroup = 0;
for i = 1:length(allAxes)
    if isappdata(allAxes(i),'graphics_linkaxes_targets') 
        num = getappdata(allAxes(i),'graphics_linkaxes_targets'); 
        targets{num} = [targets{num} allAxes(i)];
        if isempty(props{num})
            props{num} = getappdata(allAxes(i),'graphics_linkaxes_props');  
        end
        rmappdata(allAxes(i),'graphics_linkaxes_targets'); 
        rmappdata(allAxes(i),'graphics_linkaxes_props');
        if num > maxGroup, maxGroup = num; end
    end
end
targets = targets(1:maxGroup); 
props = props(1:maxGroup);
for i = 1:maxGroup
    linkaxes(targets{i},props{i}); 
end

% from "old" fig -> "new" fig restore the subplot listeners
% within "old" struct field name is SubplotListeners and SubplotDeleteListeners

% special treatment for 2006a
shouldInstallLM = true;
if length(allAxes)> 1  % only check figure contains the subplot
    if isappdata(allAxes(1),'SubplotInsets')
        shouldInstallLM = false ;
    end
end

lm =  matlab.graphics.internal.SubplotListenersManager();
%lm.helper = 0 ;  % trigger set.helper
for iter = 1: length(h)
   if (ishghandle(h(iter))) 
       if (isappdata(h(iter),'SubplotListenersManager') || isappdata(h(iter),'SubplotListeners')) && shouldInstallLM
           if isappdata(h(iter),'SubplotGrid')
               sgold = getappdata(h(iter),'SubplotGrid');
               gridsize = size(sgold);
               sgnew = matlab.graphics.axis.Axes.empty;
               for ix=1:numel(sgold)
                   if (0 ~= sgold(ix))
                    [r,c] = ind2sub(gridsize,ix);
                    a = closest_axes(allAxes,[r,c],gridsize);
                    if ~isempty(a)
                        sgnew(r,c) = a;
                    end
                   end                   
               end
               if ~isempty(sgnew)
                   setappdata(h(iter),'SubplotGrid',sgnew);
               end
           end           
           
           lm.helper = 0; 
           setappdata(h,'SubplotListenersManager',lm);
       end
   end
end

for iterH = 1: length(h)
    if ishghandle(h(iterH)) 
        if isappdata(h(iterH),'SubplotListeners')
            allAxes = get(h(iterH),'Children');
            for iterA = 1: length(allAxes)
                if isappdata(allAxes(iterA),'SubplotDeleteListener')  % no -s in "old" system
		    dlm = matlab.graphics.internal.SubplotDeleteListenersManager();
                    dlm.addToListeners(allAxes(iterA));
                    setappdata(allAxes(iterA),'SubplotDeleteListenersManager',dlm);
                    rmappdata(allAxes(iterA),'SubplotDeleteListener');
                end
            end
        end
    end
end

function a = closest_axes(allAxes, pos, gridsize)
    
    a = [];
    
    left   = (pos(2)-1)/gridsize(2);
    right  =  pos(2)   /gridsize(2);
    top    =  pos(1)   /gridsize(1);
    bottom = (pos(1)-1)/gridsize(1);
    
    for ix=1:numel(allAxes)
        if strcmp(allAxes(ix).Units,'normalized')
            thisp = allAxes(ix).Position;
            if (thisp(1) > left && (thisp(1)+thisp(3)) < right && thisp(2) > bottom && (thisp(2)+thisp(4)) < top)
                a = [a, allAxes(ix)];
            end
        end
    end

    if length(a) > 1
        for ix=1:length(a)
            if isappdata(a(ix),'SubplotPosition')
                a = a(ix);
                return
            end
        end
        
        a = a(1);
    end
