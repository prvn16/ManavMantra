classdef (Abstract) ActionBehavior_Items < handle
    % Mixin class inherited by ListBox and DropDown
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, SetAccess = {?matlab.ui.internal.toolstrip.base.Component})
        % Property "Items":
        %
        %   The list of items with states and labels. It is a nx2 cell
        %   array of strings.  The states are strings stored in the first
        %   column.  The labels are strings stored in the second column.
        %   The default value is {}. It is read-only.  To add/remove an
        %   item, use corresponding methods.
        %
        %   Example:
        %       combo = matlab.ui.internal.toolstrip.CombokBox({'state1' 'label1';'state2' 'label2';'state3' 'label3'})
        %       combo.Items % returns {'state1' 'label1';'state2' 'label2';'state3' 'label3'}
        Items
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        % Items
        function value = get.Items(this)
            % GET function for Items property.
            action = this.getAction;
            value = action.Items;
        end
        function set.Items(this, value)
            % SET function
            action = this.getAction();
            action.Items = value;
        end
        
        %% Public API: item management
        function this = addItem(this, item, varargin)
            % Method "addItem":
            %
            %   "addItem(control, state)": add a new item at the end of the
            %   list with state.  The label is the same as the state.
            %   Example:
            %       combobox = matlab.ui.internal.toolstrip.DropDown({'a','b'})
            %       combobox.addItem('c')
            %
            %   "addItem(control, {state, label})": add a new item at the end
            %   of the list with both state and label.
            %   Example:
            %       combobox = matlab.ui.internal.toolstrip.DropDown({'a','aLabel';'b','bLabel'})
            %       combobox.addItem({'c','cLabel'})
            %
            %   "addItem(control, state, index)": insert a new item
            %   Example:
            %       combobox = matlab.ui.internal.toolstrip.DropDown({'a','b'})
            %       combobox.addItem('c', 1)
            %
            %   "addItem(control, {state, label}, index)": insert a new
            %   item with both state and label.
            %   Example:
            %       combobox = matlab.ui.internal.toolstrip.DropDown({'a','aLabel';'b','bLabel'})
            %       combobox.addItem({'c','cLabel'},1)
            %
            % Note that "addItem" method does not change the current selected item.
            ni = nargin-1;
            action = this.getAction;
            item = matlab.ui.internal.toolstrip.base.Utility.hString2Char(item);
            if ni == 1
                if ischar(item)
                    % additem(state)
                    action.Items = [action.Items; {item, item}];
                elseif iscell(item) && isvector(item) && length(item)==2 && all(cellfun(@ischar, item))
                    % additem({state, label})
                    action.Items = [action.Items; item];
                else
                    error(message('MATLAB:toolstrip:control:invalidAddItem1'))
                end
            elseif ni == 2
                index = varargin{1};
                if matlab.ui.internal.toolstrip.base.Utility.validate(index, 'integer') && index >= 1 && index <= size(this.Items,1)+1
                    if ischar(item)
                        % additem(state, index)
                        action.Items = [action.Items(1:index-1,:); {item, item}; action.Items(index:end,:)];
                    elseif iscell(item) && isvector(item) && length(item)==2 && all(cellfun(@ischar, item))
                        % additem({state, label}, index)
                        action.Items = [action.Items(1:index-1,:); item; action.Items(index:end,:)];
                    else
                        error(message('MATLAB:toolstrip:control:invalidAddItem1'))
                    end
                else
                    error(message('MATLAB:toolstrip:control:invalidAddItem2'))
                end
            else
                error(message('MATLAB:toolstrip:control:invalidAddItem3'))
            end
        end
        
        function this = removeItem(this, arg)
            % Method "removeItem":
            %
            %   "removeItem(control, item)": remove the item from the list.
            %   Example:
            %       combobox = matlab.ui.internal.toolstrip.DropDown({'a';'b'})
            %       combobox.removeItem('a')
            %
            %   "removeItem(control, i)": remove the ith item from the list.
            %   Example:
            %       combobox = matlab.ui.internal.toolstrip.DropDown({'a';'b'})
            %       combobox.removeItem(1)
            %
            % Note that if the "SelectedItem" is removed, it automatically
            % becomes unselected.
            action = this.getAction;
            arg = matlab.ui.internal.toolstrip.base.Utility.hString2Char(arg);
            if ischar(arg)
                idx = strcmp(arg, this.Items(:,1));
                if sum(idx)==0
                    error(message('MATLAB:toolstrip:control:invalidRemoveItem1'))
                end
            elseif isnumeric(arg) && isscalar(arg) && isfinite(arg)
                idx = round(arg);
                if idx<1 || idx>size(this.Items,1)
                    error(message('MATLAB:toolstrip:control:invalidRemoveItem2'))
                end
            else
                error(message('MATLAB:toolstrip:control:invalidRemoveItem3'))
            end
            action.Items(idx,:) = [];
        end
        
        function this = replaceAllItems(this, items)
            % Method "replaceAllItems":
            %
            %   "replaceAllItems(control, states)": refresh the list with
            %   new items.  The labels are the same as states.
            %   Example:
            %       combobox = matlab.ui.internal.toolstrip.DropDown({'a','b'})
            %       combobox.replaceAllItems({'c', 'd'})
            %
            %   "replaceAllItems(control, items)": refresh the list with new items.
            %   Example:
            %       combobox = matlab.ui.internal.toolstrip.DropDown({'a','aLabel';'b','bLabel'})
            %       combobox.replaceAllItems({'c','cLabel';'d','dLabel'})
            %
            % Note that "SelectedItem" automatically becomes unselected.
            action = this.getAction;
            if matlab.ui.internal.toolstrip.base.Utility.validate(items, 'stringNx1')
                % replaceAllItems(states)
                action.Items = [items items];
            elseif matlab.ui.internal.toolstrip.base.Utility.validate(items, 'stringNx2')
                % replaceAllItems(items)
                action.Items = items;
            else
                error(message('MATLAB:toolstrip:control:invalidItems'))
            end
            % force items to be created before value is selected
            action.synchronize();
        end
        
    end
    
end
