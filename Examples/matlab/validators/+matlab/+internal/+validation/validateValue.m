function newValue = validateValue(validation, oldValue)
%Convert and validate value using meta.Validation. 
%
% Copyright 2017 The MathWorks, Inc 

    if ~isa(validation, 'meta.Validation') || ~isscalar(validation)
        error(message('MATLAB:type:NonScalarValidation'));
    end
    
    % do class conversion
    if ~isempty(validation.Class)
        className = validation.Class.Name;
    
        if ~isa(oldValue, className)
            try
                oldValue = builtin('_convert_to_class', className, oldValue);
            catch me
                msg = message('MATLAB:type:PropSetClsMismatch', className);
                throwAsCaller(MException(me.identifier, msg.getString));
            end
        end
    end
    
    % do size conversion
    if ~isempty(validation.Size)
        try
            if isempty(oldValue)
                indices = char(GetDimensions(validation.Size));
                eval(['temp=' 'reshape(oldValue,' indices ');']);
            else
                indices = char(GetSubscripts(validation.Size));
                eval(['temp' indices '=oldValue;']);
            end
        catch me
            if isScalarSize(validation.Size)
                throwAsCaller(MException('MATLAB:type:InvalidInputSize', message('MATLAB:type:PropSetDimMismatchScalar').getString));
            elseif isFixedSize(validation.Size)
                msg = message('MATLAB:type:PropSetDimMismatchNonScalar', char(GetDiplaySize(validation.Size)));
                throwAsCaller(MException('MATLAB:type:InvalidInputSize', msg.getString));
            else
                msg = message('MATLAB:type:PropSetDimMismatchScalarCompat', char(GetDiplaySize(validation.Size)));
                throwAsCaller(MException('MATLAB:type:InvalidInputSize', msg.getString));
            end
        end
    else
        temp = oldValue;
    end
    
    % apply validators
    vfcns = validation.ValidatorFunctions;
    for i=1:numel(vfcns)
        try
            vfcns{i}(temp);
        catch me
            throwAsCaller(me);
        end
    end
    
    newValue = temp;
end

function indices = GetSubscripts(sz)
% Returns a string which represents the subscript indices
% from meta.ArrayDimension. The returned values are suitable
% to be used by subscripted assignments.
% E.g. (2,:) => "(1:2, :)"
    indices = "";
    for i=1:numel(sz)
        if isa(sz(i), 'meta.FixedDimension')
            indices(i) = "1:" + string(sz(i).Length);
        elseif isa(sz(i), 'meta.UnrestrictedDimension')
            indices(i) = ":";
        else
            indices(i) = string(sz(i).Name);
        end

    end

    indices = join(indices, ',');
    indices = "(" + indices + ")";
end


function indices = GetDimensions(sz)
% Returns a string which represents the dimensions
% from meta.ArrayDimension. The returned values are suitable
% as inputs to reshape to create different sizes of empty arrays.
% E.g. (2,:) => "(2, 0)"
    indices = "";
    for i=1:numel(sz)
        if isa(sz(i), 'meta.FixedDimension')
            indices(i) = string(sz(i).Length);
        elseif isa(sz(i), 'meta.UnrestrictedDimension')
            indices(i) = "0";
        else
            indices(i) = string(sz(i).Name);
        end
    end
    
    indices = join(indices, ',');
end

function indices = GetDiplaySize(sz)
% Returns a string which represents the dimensions
% from meta.ArrayDimension. The returned values are suitable
% as inputs to reshape to create different sizes of empty arrays.
% E.g. (2,:) => "2x0"
    indices = "";
    for i=1:numel(sz)
        if isa(sz(i), 'meta.FixedDimension')
            indices(i) = string(sz(i).Length);
        elseif isa(sz(i), 'meta.UnrestrictedDimension')
            indices(i) = "D" + string(i);
        else
            indices(i) = string(sz(i).Name);
        end
    end
    
    indices = join(indices, 'x');
end

function tf = isScalarSize(sz)
    for i=1:numel(sz)
        if ~isa(sz(i), 'meta.FixedDimension') || sz(i).Length ~= 1
            tf = false;
            return;
        end
    end
    tf = true;
end

function tf = isFixedSize(sz)
    for i=1:numel(sz)
        if ~isa(sz(i), 'meta.FixedDimension')
            tf = false;
            return;
        end
    end
    tf = true;
end
