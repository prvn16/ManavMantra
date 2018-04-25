%CategoricalAdaptor Adaptor class for categorical data
%   Adapts subsasgn to allow tc(tc=='foo') = 'bar';
%   and disallows flags to MIN/MAX.

% Copyright 2016-2017 The MathWorks, Inc.
classdef CategoricalAdaptor < ...
        matlab.bigdata.internal.adaptors.AbstractAdaptor & ...
        matlab.bigdata.internal.adaptors.GeneralArrayDisplayMixin & ...
        matlab.bigdata.internal.adaptors.GeneralArrayParenIndexingMixin & ...
        matlab.bigdata.internal.adaptors.NoCellIndexingMixin

    properties (SetAccess = immutable)
        IsOrdinal
        IsProtected
    end

    methods (Access = protected)
        function m = buildMetadataImpl(obj)
            m = matlab.bigdata.internal.adaptors.CategoricalMetadata(obj.TallSize);
        end
    end

    methods
        function obj = CategoricalAdaptor(example)
            obj@matlab.bigdata.internal.adaptors.AbstractAdaptor('categorical');
            if nargin>0
                obj.IsOrdinal = isordinal(example);
                obj.IsProtected = isprotected(example);
            else
                obj.IsOrdinal = false;
                obj.IsProtected = false;
            end
        end

        function names = getProperties(~)
            names = {};
        end

        function out = subsasgnParens(obj, pa, szPa, S, b)
        % For categorical SUBSASGN, if 'b' is a char-vector, wrap it in a cell before
        % calling the mixin version of SUBSASGN.
            if ischar(b)
                b = {b};
            end
            out = subsasgnParens@matlab.bigdata.internal.adaptors.GeneralArrayParenIndexingMixin(...
                obj, pa, szPa, S, b);
        end

        function [nanFlagCell, precisionFlagCell] = interpretReductionFlags(~, FCN_NAME, flags)

            % Categorical family types don't have any precision flags
            precisionFlagCell = {};
            omitFlags = {'omitnan'};
            includeFlags = {'includenan'};
            % For categorical the only valid flag is 'omitnan' /
            % 'includenan', so we can use relatively simple parsing here.
            nanFlagCell = cell(1, numel(flags));
            for idx = 1:numel(flags)
                nanFlagCell{idx} = iExtractNanFlag(FCN_NAME, flags{idx}, omitFlags, includeFlags);
            end

            if ismember(lower(FCN_NAME), {'median'}) && isempty(nanFlagCell)
                % For MEDIAN we always need to provide a default NaN flag
                nanFlagCell = {'includenan'};
            elseif numel(nanFlagCell) > 1
                error(message('MATLAB:bigdata:array:InvalidRepeatedFlag', FCN_NAME, ...
                              strjoin([omitFlags, includeFlags])));
            end
        end
    end

    methods (Access = protected)
        % Build a sample of the underlying data.
        function sample = buildSampleImpl(obj, ~, sz)
            sample = repmat(categorical(1, 'Protected', obj.IsProtected, 'Ordinal', obj.IsOrdinal), sz);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract a single omit/include flag.
function nf = iExtractNanFlag(FCN_NAME, flag, omitFlags, includeFlags)
    n = numel(flag);
    if n > 0 && any(strncmpi(flag, omitFlags, n))
        nf = 'omitnan';
    elseif n > 0 && any(strncmpi(flag, includeFlags, n))
        nf = 'includenan';
    else
        validFlagsStr = strjoin([omitFlags, includeFlags]);
        error(message('MATLAB:bigdata:array:InvalidOption', flag, FCN_NAME, validFlagsStr));
    end
end
