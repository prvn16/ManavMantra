classdef tstableadaptor < matlab.mixin.SetGet & matlab.mixin.Copyable
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetObservable, GetObservable)
        Timeseries;
        EventRows;
        Time;
        Data;
        Quality;
        Table;
        ScrollPane;
        TableModel;
        NewEditRow;
        NewEditRowNumber;
        Tslistener;
    end
    
    methods
        newrow(h,newrow,varargin)
    end
    
    methods (Hidden)
        addrow(h)
        tablePanel = addtopanel(h,host)
        build(h)
        delrow(h)
        setdata(h,newValue,row,col)
    end
end