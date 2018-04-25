function updatecache(h,row)

% Copyright 2006-2011 The MathWorks, Inc.
thisCache = tsguis.UpdateArrayEditorTableCache(h.Timeseries,row,0);
h.TableModel.setCache(thisCache);

