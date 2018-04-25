function updateAncestorListeners(h_group,update_fcn)
%updateAncestorListeners Set up listeners to ancestors. 
%   updateAncestorListeners(H_GROUP,UPDATE_FCN) sets up listeners to all
%   ancestors of H_GROUP that have Position, XLim, or YLim properties. H_GROUP
%   is an hggroup object. UPDATE_FCN is a function handle that is called when
%   any of the ancestor properties change.
% 
%   It's important to use updateAncestorListeners when you are drawing objects
%   in a way that may depend on the current Position, XLim, or YLim properties
%   of ancestors. If these properties change, you need to redraw your
%   object. Using updateAncestorListeners makes the code drawing objects more
%   robust to user actions like zooming and resizing.

%   Copyright 2005-2014 The MathWorks, Inc.
  
% Clear the old listeners.
setappdata(h_group, 'AncestorPositionListeners', []);

h_parent = get(h_group, 'Parent');
root = 0;
listeners = {};

property_list_all = {'Position', 'XLim', 'YLim'};
property_list_subset = {'XLim', 'YLim'};

event_list = {'SizeChanged', 'LocationChanged'};

while h_parent ~= root
  % Some ancestor objects might not have Position properties.
  properties = get(h_parent);
  % Axes has Position PostSet events
  if strcmp(get(h_parent,'Type'), 'axes')
      property_list = property_list_all;
  else
      property_list = property_list_subset;
  end
  for k = 1:numel(property_list)
    property = property_list{k};
    if isfield(properties, property)
        listener = iptui.iptaddlistener(h_parent, ...
            property, ...
            'PostSet', update_fcn);
      if isempty(listeners)
        listeners = {listener};
      else
        listeners{end + 1} = listener; %#ok<AGROW>
      end
    end
  end
  
  allEvents = events(h_parent);
  for k = 1:numel(event_list)
      theEvent = event_list{k};
      idx = strmatch(theEvent, allEvents);
      if (~isempty(idx))
          listener = iptui.iptaddlistener(h_parent, ...
            theEvent, update_fcn);
        
          if isempty(listeners)
              listeners = {listener};
          else
              listeners{end + 1} = listener; %#ok<AGROW>
          end
      end
  end
  
  h_parent = get(h_parent, 'Parent');
end

setappdata(h_group, 'AncestorPositionListeners', listeners);
