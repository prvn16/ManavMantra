function bfitlistenoff(fig)
% BFITLISTENOFF Disable listeners for Basic Fitting GUI. 

%   Copyright 1984-2014 The MathWorks, Inc. 

if ~isempty(bfitFindProp(fig, 'bfit_FigureListeners'))
    listeners = get(handle(fig), 'bfit_FigureListeners');
    bfitSetListenerEnabled(listeners.childadd, false);
    bfitSetListenerEnabled(listeners.childremove, false);
    bfitSetListenerEnabled(listeners.figdelete, false);
    bfitSetListenerEnabled(listeners.axesManagerChildadd, false);
    bfitSetListenerEnabled(listeners.axesManagerChildremove, false);
end

axesList = datachildren(fig);
lineL = plotchild(axesList, 2, true);

for i = lineL'
    if ~isempty(bfitFindProp(i, 'bfit_CurveListeners'))
	listeners = get(handle(i), 'bfit_CurveListeners');
        bfitSetListenerEnabled(listeners.tagchanged,false);
    end
    if ~isempty(bfitFindProp(i, 'bfit_CurveDisplayNameListeners'))
	listeners = get(handle(i), 'bfit_CurveDisplayNameListeners');
        bfitSetListenerEnabled(listeners.displaynamechanged,false);
    end
    
    if ~isempty(bfitFindProp(i, 'bfit_ChildDestroyedListeners'))
	listeners = get(handle(i), 'bfit_ChildDestroyedListeners');
        bfitSetListenerEnabled(listeners, false);
    end
end

axesL = findobj(fig, 'type', 'axes');
for i = axesL'
    if ~isempty(bfitFindProp(i, 'bfit_AxesListeners'))
        listeners = get(handle(i), 'bfit_AxesListeners');
        if isequal(get(i,'tag'),'legend')
            bfitSetListenerEnabled(listeners.userDataChanged,false);
        else
            bfitSetListenerEnabled(listeners.lineAdded, false);
            bfitSetListenerEnabled(listeners.lineRemoved, false);
        end
    end
end

