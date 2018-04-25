function build(h)

% Copyright 2005-2009 The MathWorks, Inc.

% Build a table of timeseries data backed by table model which uses a
% MATLAB variable.

import com.mathworks.toolbox.timeseries.*;

% Build table and model
h.TableModel = TimeSeriesObjectTableModel(h);
h.Table = javaObjectEDT('com.mathworks.toolbox.timeseries.TimeSeriesTable',...
    h.TableModel);
h.Table.setName(['TimeSeriesTable' h.Timeseries.Name]);
h.ScrollPane = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',h.Table);
h.TableModel.setTableParent(h.Table);

% Update the TimeSeriesArrayEditorTableCache with the setCache method. This
% will force a fireTableStructureChange event to build the table the first
% time it is called.
h.TableModel.setCache(tsguis.UpdateArrayEditorTableCache(h.Timeseries,0,0));

% Create data change listener to update the table
h.Tslistener = [event.listener(h.Timeseries,'Datachange',@(e,d) localUpdate(e,d,h));...
    event.listener(h.Timeseries,h.Timeseries.findprop('Name'),...
    'PropertyPostSet',@(e,d) localUpdate(e,d,h))];


function localUpdate(es,ed,h) %#ok<*INUSL>

import java.awt.*;

% Update the cache for the current scroll position
currentRow = h.Table.rowAtPoint(Point(0,h.ScrollPane.getVerticalScrollBar.getValue));
newCache = tsguis.UpdateArrayEditorTableCache(h.Timeseries,currentRow,0);
h.TableModel.setCache(newCache);
