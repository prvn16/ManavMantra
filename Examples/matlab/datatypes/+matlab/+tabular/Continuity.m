classdef Continuity
%CONTINUITY Enumeration class representing VariableContinuity types
%   Continuity is an enumeration class used to set the VariableContinuity
%   property of variables in tables and timetables, which specifies whether
%   a variable represents continuous or discrete data values.
%   
%   C = Continuity(TYPE) creates an enumeration member of given TYPE. TYPE
%   is a string or a character vector with four possible values: unset,
%   continuous, step, and event.
%
%   See also: TABLE, TIMETABLE, RETIME, SYNCHRONIZE.
%
%   Copyright 2016-2017 The MathWorks, Inc.

    enumeration
        unset              ("fillwithmissing","plot")
        continuous         ("linear","plot")
        step               ("previous","stair")
        event              ("fillwithmissing","scatter")
    end    
    
    properties
        InterpolationMethod
        PlotType
    end
    
    methods
        function obj = Continuity(m,pt)
            obj.InterpolationMethod = m;
            obj.PlotType = pt;
        end
    end
end
