function obj = loadObjectArray(B)
%    Copyright 2017 The MathWorks, Inc.

if isstruct(B) && isfield(B, 'version') && B.version == 3
    if isa(B.Name, 'cell') %A cell array of names implies an array of timers
        obj = [];
        for index = 1:length(B.Name)
            obj = horzcat(obj,timer);
            instance = obj(index);
            vals = getSettableValues(instance);
            for i = 1:length(vals)
                set(instance, vals{i}, B.(vals{i}){index});
            end
        end
    else
        obj = timer;
        vals = getSettableValues(obj);
        for i = 1:length(vals)
            set(obj, vals{i}, B.(vals{i}));
        end
    end
elseif isempty(B)
    obj = timer.empty(size(B));
elseif isstruct(B) && isfield(B,'jobject')
    for i = 1:numel(B.jobject)
        if isa(B.jobject(i),'javahandle.com.mathworks.timer.TimerTask')  %8a style load.  (version 2)
            s.jobject = B.jobject(i);
            obj(i) = timer(s);
        else % Timer is invalid.
            obj(i) = timer;
            delete(obj(i));
        end
    end
    if isfield(B,'ud') && (numel(B.ud) == numel(obj))
        for i = 1:numel(obj)
            if isvalid(obj(i))
                set(obj(i), 'Userdata', B.ud{i});
            end
        end
    end
else
    obj = B;
end
