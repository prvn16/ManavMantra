classdef DataTypeStrings < handle
% fxptds.DataTypeStrings class

% class which enlists data type strings used to set SpecifiedDT /
% ProposedDT fields of fxptds.AbstractResult
% Used by fxptds.FPTEventHandler and fxptds.AbstractResult.setProposedDT

%   Copyright 2016 The MathWorks, Inc.

    properties(Constant)
        notApplicable = 'n/a';
        locked = DAStudio.message('FixedPointTool:fixedPointTool:Locked');
    end
end
