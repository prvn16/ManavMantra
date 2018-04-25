function validateAndSetLimits(ax, new_xlim, new_ylim, new_zlim)

ThreeD = false;
if nargin == 4
    ThreeD = true;
end

% Make sure limits are valid (will throw out NaNs as well)
if any(isnan(new_xlim)) || any(isnan(new_ylim))
    return
end

if ThreeD && any(isnan(new_zlim))
    return
end

if isprop(ax,'ActiveXRuler')
    new_xlim = matlab.graphics.internal.lim2ruler(new_xlim, ax.ActiveXRuler);
    new_ylim = matlab.graphics.internal.lim2ruler(new_ylim, ax.ActiveYRuler);
    if ThreeD
        new_zlim = matlab.graphics.internal.lim2ruler(new_zlim, ax.ActiveZRuler);
    end
end
ax.XLim = sort(new_xlim);
ax.YLim = sort(new_ylim);
if ThreeD
    ax.ZLim = sort(new_zlim);
end
drawnow update; % Needed to stop motion events queuing
