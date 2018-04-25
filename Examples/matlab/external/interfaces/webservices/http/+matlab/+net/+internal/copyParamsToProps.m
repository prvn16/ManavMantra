function obj = copyParamsToProps(obj, args)
%copyParamsToProps copies the Name,Value arguments to the properties of obj
%   Accepts char or string for Name.  The set methods in obj are expected to validate
%   values of the properties.

% Copyright 2015-2016 The MathWorks, Inc

    p = inputParser;
    props = properties(obj);
    for i = 1 : length(props)
        p.addParameter(props{i}, obj.(props{i}));
    end
    p.FunctionName = class(obj);
    try
        for i = 1 : 2 : length(args)
            if isstring(args{i})
                args{i} = char(args{i});
            end
            % test for this because inputParser thinks empty matches everything
            if isempty(args{i})
                error(message('MATLAB:http:ArgMustBeString',i));
            end
        end
        p.parse(args{:});

        inputs = p.Results;
        names = fieldnames(inputs);
        for i = 1 : length(names)
            name = names{i};
            value = inputs.(name);
            obj.(name) = value;
        end
    catch e
        throwAsCaller(e);
    end
end

