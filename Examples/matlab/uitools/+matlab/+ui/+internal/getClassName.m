function className=getClassName(object)
% This undocumented function may be removed in a future release.

% Copyright 2010 The MathWorks, Inc.

% Returns the runtime class of object or empty array if this information is
% not available.

if (nargin ~= 1)
   error(message('MATLAB:getClassName:nargin'));
 end
 
if (nargout ~= 1)
   error(message('MATLAB:getClassName:nargout'));
end

className=[];

if isempty(object)
    return;
end

if ishandle(object)
    hObj = handle(object);
    if ~isobject(hObj)
        % that's how it is done in HG one
        hCls = classhandle(hObj);
        hPk = get(hCls,'Package');
        if ~isempty(hPk)
            className = [get(hPk,'Name'), '.',get(hCls,'Name')];
        else
            className=get(hCls,'Name');
        end
    else
        className=class(hObj);
    end
    
else
    className=class(object);
end

end