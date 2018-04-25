function group = createModifiedPropGroup(h)
%createModifiedPropGroup  Build group of properties with modified values
%    Construct a single matlab.mixin.util.PropertyGroup instance containing
%    the names of all public properties of input object h with values that
%    differ from their defaults.

%   Copyright 2013 The MathWorks, Inc.
    modprops = {};
    p = properties(h);
    for i=1:length(p)
        pi = findprop(h,p{i});
        if pi.Dependent
            mpi = findprop(h,[pi.Name 'Mode']);
            if ~isempty(mpi)
                mode = get(h,mpi.Name);
                if strcmpi( mode, 'Manual')
                    modprops{end+1} = pi.Name; %#ok<AGROW>
                end
            end
        end
    end
    group = matlab.mixin.util.PropertyGroup(modprops);
end
