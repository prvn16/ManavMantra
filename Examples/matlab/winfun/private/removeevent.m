function error = removeevent(h, eventname, eventhandler)
% Copyright 1984-2004 The MathWorks, Inc.

%find out if property exist, if there are no events
% property should not exist
p = findprop(h, 'MMListeners_Events');
if (isempty(p))
    error = 1;
    return;
end

p.AccessFlags.Publicget = 'on';
p.AccessFlags.Publicset = 'on';

%dont proceed if no events are registered
list = h.MMListeners_Events;

[row,col] = size(list);
if(row == 0)
    error = 1;
    return;
end    

for i=1:row
    tempevent = list(i).EventType;
    tempcallback = list(i).Callback(2);

    if (strcmpi(eventname, tempevent))
        if (isa(eventhandler, 'function_handle') && isequal(eventhandler, tempcallback{1})) || ...
                (ischar(eventhandler) && strcmpi(eventhandler, tempcallback))

            list(i) = [];
            h.MMListeners_Events = list;
            %check the size, if 0, delete the property
            [row,col] = size(h.MMListeners_Events);
            if (row == 0)
                p = findprop(h, 'MMListeners_Events');
                if (~isempty(p))
                    delete(p);
                end
            else
                p.AccessFlags.Publicget = 'off';
                p.AccessFlags.Publicset = 'off';
            end

            error = 0;
            return;
        end
    end
end

p.AccessFlags.Publicget = 'off';
p.AccessFlags.Publicset = 'off';

%str = sprintf('Cannot unregister ''%s''. Invalid event name/handler combination', eventname);
%warning('MATLAB:removeevent:InvalidEvent', str);
error = 1;

