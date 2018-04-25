%TableAdaptor Adaptor class for tabular tall arrays.

% Copyright 2016-2017 The MathWorks, Inc.

classdef TableAdaptor < matlab.bigdata.internal.adaptors.TabularAdaptor

    methods (Access = protected)
        function m = buildMetadataImpl(obj)
            m = matlab.bigdata.internal.adaptors.TableMetadata(obj.TallSize);
        end
        
        function obj = buildDerived(~, varNames, varAdaptors, dimNames, rowAdaptor, newProps)
            if ~isempty(rowAdaptor)
                error(message('MATLAB:bigdata:table:SetRowNamesUnsupported'));
            end
            obj = matlab.bigdata.internal.adaptors.TableAdaptor(...
                varNames, varAdaptors, dimNames, newProps);
        end
        
        function previewData = fabricatePreview(obj)
            previewData = fabricateTabularPreview(obj, obj.VariableNames);
        end
        
        function data = getRowProperty(~, ~)
            data = {};
        end
        
        function throwCannotDeleteRowPropertyError(~)
            error(message('MATLAB:bigdata:table:DeleteRowNamesUnsupported'));
        end
        
        function errorIfFirstSubSelectingRowsNotSupported(~,firstSub)
            if ~matlab.bigdata.internal.util.isColonSubscript(firstSub)
                if (ischar(firstSub) || iscellstr(firstSub) || isstring(firstSub))
                    % Could be an attempt at row-name indexing. Not supported
                    error(message('MATLAB:bigdata:table:SubsrefRowNamesNotSupported'));
                elseif isa(firstSub,'withtol')
                    error(message('MATLAB:withtol:InvalidSubscripter'));
                elseif isa(firstSub,'timerange')
                    error(message('MATLAB:timerange:InvalidSubscripter'));
                elseif isdatetime(firstSub) || isduration(firstSub)
                    error(message('MATLAB:bigdata:table:InvalidRowSubscript'));
                end
            end
        end
        
    end
    methods
        function obj = TableAdaptor(varargin)
        % TableAdaptor constructor.
        % a = TableAdaptor(previewData) - build from preview data
        % a = TableAdaptor(varNames, varAdaptors) - build from names and adaptors
        % a = TableAdaptor(varNames, varAdaptors, dimNames, otherProperties) - internal use
        % constructor to apply 'other' properties.
            narginchk(1,4);

            className   = 'table';
            rowPropName = 'RowNames';
            rowAdaptor  = [];
            

            if nargin == 1
                % preview data
                previewData = varargin{1};
                
                dimNames = previewData.Properties.DimensionNames;
                varNames = previewData.Properties.VariableNames;
                varAdaptors = cellfun( ...
                    @(vn) matlab.bigdata.internal.adaptors.getAdaptorFromPreview(previewData{[],vn}), ...
                    varNames, 'UniformOutput', false);

                % Copy 'Properties' from the preview data
                otherProps  = previewData.Properties;
            else
                assert(nargin == 2 || nargin == 4, ...
                    'Assertion failed: TableAdaptor requires 2 or 4 inputs.');
                [varNames, varAdaptors] = deal(varargin{1:2});
                if nargin == 4
                    [dimNames, otherProps] = deal(varargin{3:4});
                else
                    t = table();
                    dimNames = t.Properties.DimensionNames;
                    otherProps = t.Properties;
                end
            end

            obj@matlab.bigdata.internal.adaptors.TabularAdaptor(...
                className, dimNames, varNames, varAdaptors, ...
                rowPropName, rowAdaptor, otherProps);
        end
    end

    methods (Access = protected)
        % Build a sample of the underlying data.
        function sample = buildSampleImpl(obj, defaultType, sz)
            fcn = @(rowNames, varargin) table(varargin{:}, 'RowNames', rowNames);
            sample = buildTabularSampleImpl(obj, fcn, defaultType, sz);
        end
                
        function out = subsasgnRowProperty(adap, pa, ~, b)
            % Assign ROWNAMES. Actual values are not supported, but we allow {}.
            if ~istall(b) && isequal(b,{})
                % Nothing to do. Just build the output from the input.
                out = tall(pa, adap);
                return
            end
            
            % If non-tall is specified, throw the standard MATLAB error
            if ~istall(b)
                error(message('MATLAB:table:InvalidRowNames'));
            end
            
            % All other cases are unsupported
            error(message('MATLAB:bigdata:table:SetRowNamesUnsupported'));
        end
    end
end

