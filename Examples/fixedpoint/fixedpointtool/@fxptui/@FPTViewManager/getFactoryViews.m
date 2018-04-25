function factoryViews = getFactoryViews(this, name)
%GETFACTORYVIEWS Get the factoryViews.
%   OUT = GETFACTORYVIEWS(ARGS) <long description>

%   Copyright 2010-2014 The MathWorks, Inc.


factoryViews = [];

switch nargin
    case 2
        % Return the requested factory view
        index = find(strncmp(this.FactoryMap(:, 1), name, length(name)), 1);
        if ~isempty(index)
            factoryViews = feval(this.FactoryMap{index, 2}, this); 
        end
        % if h.FactoryMap.isKey(name)
        %     factoryViews = feval(h.FactoryMap(name), h); 
        % end
    otherwise
        % Return all factory views
        for i = 1:length(this.FactoryMap)
            view = feval(this.FactoryMap{i, 2}, this);
            factoryViews = [factoryViews view]; %#ok<AGROW>
        end
        % values = h.FactoryMap.values;
        % for i = 1:length(values)
        %     view = feval(values{i}, h);
        %     factoryViews = [factoryViews view]; %#ok<AGROW>
        % end
end

%--------------------------------------------------------
% [EOF]
