function retval = is2D(ax)
% Internal use only. This function may be removed in a future release.

% Copyright 2002-2015 The MathWorks, Inc.

%IS2D Return true if ax is a 2-D Polar or Cartesian axes

if isempty(ax)
    retval = false;
    return;
end

% For now, just consider x-y plots. A more generic version is 
% commented out below.

if ~isscalar(ax)
   N = length(ax);
   retval = false(1,N);
   for n = 1:N
      retval(n) = testOneAxes(ax(n));
   end
else
    retval = testOneAxes(ax);
end

function result = testOneAxes(ax)
if isa(ax,'matlab.graphics.chart.Chart')
    result = false;
else    
    VIEW_2D = [0,90];
    hax = handle(ax);
    ax_view = get(ax,'View');
    if strcmp(hax.Type, 'axes') && hasCameraProperties(hax)
        camUp = get(ax,'CameraUpVector');
        result = isequal(ax_view,VIEW_2D) && isequal(abs(camUp),[0 1 0]);
    else
        result = isequal(ax_view,VIEW_2D);
    end
end
   

%--Uncomment this code for generic 2-D plot support--%

%test to see if viewing plane is parallel to major axis (x,y, or z)
%test1 = logical(sum(campos(ax)-camtarget(ax)==0)==2);
% 
% % test to see if upvector is orthogonal to primary axes
% if (test1)
%     cup = camup(ax);
%     I = find(( (campos(ax)-camtarget(ax)) ==0 )==1);
%     test2 = sum(cup(I)~=0)~=2;
%      
%     % test to see if projection is orthographic
%     if(test2)
%         retval = strcmpi(get(ax,'Projection'),'Orthographic');
%     end
% end
