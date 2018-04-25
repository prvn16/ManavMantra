function data = flatten(data)
% flatten Flatten a cell array (remove all nesting).
    %import matlab.depfun.internal.flatten
    if iscell(data)
        data = cellfun(@matlab.depfun.internal.flatten,data,'UniformOutput',false);
        if any(cellfun(@iscell,data))
            data = [data{:}];
        end
    end
end



