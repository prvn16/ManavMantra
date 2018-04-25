function isSL = isslhandle(h)
%ISSLHANDLE True for Simulink object handles for models or subsystem.
%   ISSLHANDLE(H) returns an array that contains 1's where the elements of
%   H are valid printable Simulink object handles and 0's where they are not.

%   Copyright 1984-2015 The MathWorks, Inc.

narginchk(1,1)

persistent isSimulinkPresent;
if isempty(isSimulinkPresent)
    isSimulinkPresent = exist('is_simulink_loaded'); %#ok<EXIST>
end

if ~(isSimulinkPresent && is_simulink_loaded)
    isSL = zeros(size(h));
    return
end

%See if it is a handle of some kind
isSL = ~ishghandle(h);
for i = 1:length(h(:))
    if isSL(i)
        %If can not GET the Type of the object then it is not an HG object.
        try
            isSL(i) = strcmp( 'block_diagram', get_param( h(i), 'type' ) );
            if ~isSL(i)
                isSL(i) = strcmp( 'SubSystem', get_param( h(i), 'blocktype' ) );
            end
        catch
            isSL(i) = false;
        end
    end
end