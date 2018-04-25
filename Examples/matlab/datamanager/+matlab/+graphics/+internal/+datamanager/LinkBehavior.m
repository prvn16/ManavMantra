classdef LinkBehavior < matlab.graphics.internal.HGBehavior
%This is an undocumented class and may be removed in future
%
% Copyright 2013-2015 MathWorks, Inc.


properties
    %DATASOURCE Properties take any character 
    XDataSource = '';
    YDataSource = '';
    ZDataSource = '';
    UsesXDataSource = false;
    UsesYDataSource = false;
    UsesZDataSource = false;
    DataSourceFcn = [];

    % LINKBRUSHQUERYFCN Property takes a cell array with 
    % first cell a function handle. The function should 
    % take a brush region and determine which data points
    % fall within the brushed region. This should be query
    % only function and should not modify the chart object.
    LinkBrushQueryFcn = [];

    % LINKBRUSHUPDATEIFCN Property takes a cell array with 
    % first cell a function handle. This function is optional,
    % and should only be set if any custom updating is needed
    % before updating the variable brushing arrays.
    LinkBrushUpdateIFcn = [];

    % LINKBRUSHUPDATEOBJFCN Property takes a cell array with 
    % first cell a function handle. This function is optional,
    % and should only be set if any custom updating of the chart
    % object is necessary after each time it is brushed.
    LinkBrushUpdateObjFcn = [];

    BrushFcn = [];
    UserData = [];
    %ENABLE Property takes true/false
    Enable = true;
    %SERIALIZE Property takes true/false
    Serialize = false;
end

properties (Constant)
    %NAME Property is read only
    Name = 'Linked';
end


methods
    function ret = dosupport(~,hTarget)
        ret = ishghandle(hTarget);
    end
    
    function tf = islinked(hlink)
        tf = (~hlink.UsesXDataSource || ~isempty(hlink.XDataSource)) && ...
            (~hlink.UsesYDataSource || ~isempty(hlink.YDataSource)) && ...
            (~hlink.UsesZDataSource || ~isempty(hlink.ZDataSource));
    end
end

end  % classdef

