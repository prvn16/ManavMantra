%TimetableAdaptor Adaptor class for tabular tall arrays.

% Copyright 2016-2017 The MathWorks, Inc.

classdef TimetableAdaptor < matlab.bigdata.internal.adaptors.TabularAdaptor
    methods (Access = protected)
        function m = buildMetadataImpl(obj)
        % SUMMARY is not currently supported for tall timetable, so simply gather
        % generic metadata.
            m = matlab.bigdata.internal.adaptors.GenericArrayMetadata(obj.TallSize);
        end

        function obj = buildDerived(~, varNames, varAdaptors, dimNames, rowAdaptor, newProps)
            if ~ismember(rowAdaptor.Class, {'datetime', 'duration'})
                error(message('MATLAB:timetable:InvalidRowTimes'));
            end
            obj = matlab.bigdata.internal.adaptors.TimetableAdaptor(...
                varNames, varAdaptors, dimNames, rowAdaptor, newProps);
        end

        function previewData = fabricatePreview(obj)
            previewData = fabricateTabularPreview(obj, [obj.DimensionNames{1}, obj.VariableNames]);
        end

        function varargout = getRowProperty(obj, pa)
        % Getting the rowtimes vector
            substr = substruct('.', obj.DimensionNames{1});
            [varargout{1:nargout}] = tall(slicefun(@subsref, pa, substr), obj.RowAdaptor);
        end

        function throwCannotDeleteRowPropertyError(~)
            error(message('MATLAB:timetable:CannotRemoveRowTimes'));
        end
        
        function errorIfFirstSubSelectingRowsNotSupported(~,~)
        % no-op for timetable
        end
        
    end

    methods
        function obj = TimetableAdaptor(varargin)
        % Supported Syntaxes:
        % Build from preview data:
        % TimetableAdaptor(previewData)
        %
        % Build with variable names, variable adaptors, dimension names, and adaptor for RowTimes:
        % TimetableAdaptor(varNames, varAdaptors, dimNames, rowtimesAdaptor)
        %
        % As above, but additionally with other elements of 'Properties'.
        % TimetableAdaptor(varNames, varAdaptors, dimNames, rowtimesAdaptor, otherProperties)

            narginchk(1,5);
            className   = 'timetable';
            rowPropName = 'RowTimes';

            if nargin == 1
                % preview data
                previewData = varargin{1};
                dimNames    = previewData.Properties.DimensionNames;
                rowAdaptor  = matlab.bigdata.internal.adaptors.getAdaptorFromPreview(previewData.(dimNames{1}));
                varNames    = previewData.Properties.VariableNames;
                varAdaptors = cellfun( ...
                    @(vn) matlab.bigdata.internal.adaptors.getAdaptorFromPreview(previewData{[],vn}), ...
                    varNames, 'UniformOutput', false);

                otherProps  = previewData.Properties;
            else
                assert(nargin == 4 || nargin == 5, ...
                    'Assertion failed: TimetableAdaptor expected 4 or 5 inputs.')
                [varNames, varAdaptors, dimNames, rowAdaptor] = deal(varargin{1:4});
                if nargin == 4
                    t = timetable();
                    otherProps = t.Properties;
                else
                    otherProps = varargin{5};
                end
            end
            obj@matlab.bigdata.internal.adaptors.TabularAdaptor(...
                className, dimNames, varNames, varAdaptors, ...
                rowPropName, rowAdaptor, otherProps);
        end

        function clz = getDimensionNamesClass(obj)
        % getDimensionNamesClass - get the class of RowTimes.
            clz = obj.RowAdaptor.Class;
        end
    end
    
    methods (Access=protected)
        % Build a sample of the underlying data.
        function sample = buildSampleImpl(obj, defaultType, sz)
            fcn = @(rowTimes, varargin) timetable(varargin{:}, 'RowTimes', rowTimes);
            sample = buildTabularSampleImpl(obj, fcn, defaultType, sz);
        end
        
        function out = subsasgnRowProperty(adap, pa, szPa, b)
            % Assign ROWTIMES
            % We simply divert this call to set tt.Time.
            subs = substruct('.', adap.DimensionNames{1});
            out = adap.subsasgnDot(pa, szPa, subs, b);
        end
    end
end
