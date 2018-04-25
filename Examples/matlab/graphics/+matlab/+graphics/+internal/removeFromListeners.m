function removeFromListeners(p, ax)
% This function is undocumented and will change in a future release

%   Copyright 2010-2013 The MathWorks, Inc.

% Create subplot listeners to align plot boxes automatically

        if isappdata(ax, 'SubplotDeleteListenersManager')
                temp = getappdata(ax, 'SubplotDeleteListenersManager');
                delete(temp.SubplotDeleteListener);
                rmappdata(ax, 'SubplotDeleteListenersManager');
        end
        slm = getappdata(p, 'SubplotListenersManager');
        slm.removeFromListeners(ax);
        
        setappdata(p, 'SubplotListenersManager', slm)
end

function dst = remove_axes(src, ax)

  n = numel(src);
  if (n > 0)
    axlistind = zeros(1,n);
    for ix=1:n
        if isa(src{ix},'event.proplistener')
            axlistind(ix) = (src{ix}.Object{1} == ax);
        elseif isa(src{ix},'event.listener')
            axlistind(ix) = (src{ix}.Source{1} == ax);
        end
    end

    dst={};
    for ix=1:n
        if axlistind(ix)
            delete(src{ix});
        else
            dst{end+1} = src{ix};
        end
    end
  end
end
