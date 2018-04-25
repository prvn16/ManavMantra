function tb = createtoolbar_search(h, varargin)
%CREATETOOLBAR_SEARCH   

%   Copyright 2008-2014 The MathWorks, Inc.

if(nargin > 1)
	tb = varargin{1};
else
	am = DAStudio.ActionManager;	
	tb = am.createToolBar(h);
end

action = am.createToolBarText(tb);
action.setText(fxptui.message('labelShow')); 
tb.addWidget(action);

searchComboBox = am.createToolBarComboBox(tb);
searchComboBox.setEditable(0);
searchComboBox.insertItems(0,{...
    fxptui.message('labelAllresults'),...
    fxptui.message('labelLoggedsignaldataresults'),...
    fxptui.message('labelMinMaxresults'),... 
    fxptui.message('labelOverflows'),...
    fxptui.message('labelConflictswithproposeddatatypes'),...
    fxptui.message('labelGroupsthatmustsharethesamedatatype')...
                   });
searchListener = handle.listener(searchComboBox,'SelectionChangedEvent',...
                                 @(s,e) localfilterresults(h,searchComboBox,s,e));
searchListener(2) = handle.listener(h,'UpdateFilterListEvent',...
                                 @(s,e) localfilterresults(h,searchComboBox,s,e));
if isempty(h.listeners)
    h.listeners = searchListener;
else
    h.listeners(end+1) = searchListener(1);
    h.listeners(end+1) = searchListener(2);
end
tb.addWidget(searchComboBox);

%-------------------------------------------------------
function localfilterresults(h,sel,~,e) 

if isa(e.Source,'DAStudio.ToolBarComboBox') || isa(e.Source,'fxptui.explorer')
    % We need to process the results from both the model and submodel
    % nodes.
    h.ResultsPaneFilteringChoice = sel.getCurrentItem;
    h.updateResultsVisibility;
    % We'll only add the DTGroup 
    vm = h.getViewManager;
    currView = vm.getActiveView;
    
    if isempty(currView)
        return;
    end
    dtProp = currView.getProperty('DTGroup');
    if isequal(h.ResultsPaneFilteringChoice, 5)
        % Expose the DTGroup column if not present already
        if isempty(dtProp)
            dtPropTransient = DAStudio.MEViewProperty('DTGroup');
            dtPropTransient.isTransient = true;
            MEView_cb([], 'doAddProperty', currView, {dtPropTransient}, 'CompiledDT');
        end
    else
        % remove the DTGroup column if we added it
        if ~isempty(dtProp) && dtProp.isTransient
            currView.removeProperty({'DTGroup'});
        end
    end

    % Fire a hierarchy change event to refresh the List View.
    node = h.getFPTRoot;
    node.fireHierarchyChanged;
    h.refreshDetailsDialog;
end

% [EOF]
