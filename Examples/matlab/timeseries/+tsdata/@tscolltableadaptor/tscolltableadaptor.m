classdef tscolltableadaptor < tsdata.tstableadaptor
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        newrow(h,newrow,~)
    end
    
    methods (Hidden)
        build(h)
        delrow(h)
        setQualityColumn(h)
        setdata(h,newValue,row,~)
        updatecache(h,row)
    end
    
end