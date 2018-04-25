%MISSING Create a missing value
%   M = MISSING returns a missing value which can be assigned into an array
%   to represent missing data. Datatypes that support missing values will
%   convert M to their native missing value.
%
%   Examples:
%
%     % Denote an element of a double array as missing
%       a = 1:5
%       a(2) = missing
%
%     % Denote several elements of a datetime array as missing
%       d = datetime:(datetime+4)
%       d([1,3,4]) = missing
%
%   See also ISMISSING, FILLMISSING, ISNAN
classdef (Sealed) missing < matlab.mixin.internal.MatrixDisplay
    methods (Hidden)
        function disp(m)
            disp(string(m));
        end
        
        function b = ismissing(m, indicators)
            if nargin > 1
                try
                    if isa(m, 'missing')
                        if ~isa(indicators, 'missing')
                            error(message('MATLAB:invalidConversion', 'missing', class(indicators)));
                        end
                    else
                        b = deferCall('ismissing', m, indicators);
                        return;
                    end
                catch ME
                    throwAsCaller(ME);
                end
            end
            b = true(size(m));
        end
        
        function d = double(m)
            d = nan(size(m));
        end
        
        function d = single(m)
            d = nan(size(m), 'single');
        end
        
        function s = string(m)
            s = string(nan(size(m)));
        end
        
        function s = struct(varargin)
            if nargin == 1
                error(message('MATLAB:invalidConversion', 'struct', 'missing'));
            else
                try
                    s = builtin('struct', varargin{:});
                catch e
                    throwAsCaller(e);
                end
            end
        end
        
        function o = horzcat(varargin)
            o = deferCall('horzcat', varargin{:});
        end
        
        function o = vertcat(varargin)
            o = deferCall('vertcat', varargin{:});
        end
        
        function o = cat(dim, varargin)
            if ismissing(dim)
                dim = nan;
            end
            varargin = convertCell(varargin);
            o = redispatch('cat', dim, varargin{:});
        end
        
        function b = isequal(varargin)
            b = false;
        end
        
        function b = isequaln(varargin)
            b = deferCall('isequaln', varargin{:});
        end
        
        function b = lt(left, right)
            b = falseExpand(left, right);
        end
        
        function b = le(left, right)
            b = falseExpand(left, right);
        end
        
        function b = gt(left, right)
            b = falseExpand(left, right);
        end
        
        function b = ge(left, right)
            b = falseExpand(left, right);
        end
        
        function b = eq(left, right)
            b = falseExpand(left, right);
        end
        
        function b = ne(left, right)
            b = ~falseExpand(left, right);
        end
    end
    
    methods (Hidden, Access=protected)
        function displayImpl(m, ~, ~)
            disp(m);
            if isscalar(m) && strcmp(matlab.internal.display.formatSpacing, 'loose')
                fprintf(newline);
            end
        end
    end
end

function arg = convertCell(arg)
    missings = cellfun(@(x)isa(x, 'missing'), arg);
    found = find(~missings, 1);
    if ~isempty(found)
        prototype = arg{found};
        try
            arg(missings) = cellfun(@(x)feval(class(prototype), repmat(missing, size(x))), arg(missings), 'UniformOutput', false);
        catch e
            e.throwAsCaller;
        end
    end
end

function b = falseExpand(left, right)
    try
        convertCell({left, right});
        b = false(size(left)) | false(size(right));
    catch e
        e.throwAsCaller;
    end
end

function o = redispatch(fcn, varargin)
    try
        if isa(varargin{end}, 'missing')
            o = builtin(fcn, varargin{:});
        else
            o = feval(fcn, varargin{:});
        end
    catch e
        e.throwAsCaller;
    end
end

function o = deferCall(fcn, varargin)
    try
        varargin = convertCell(varargin);
        o = redispatch(fcn, varargin{:});
    catch e
        e.throwAsCaller;
    end
end

