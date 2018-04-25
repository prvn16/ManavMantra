classdef TabularDatastore < ...
        matlab.io.datastore.Datastore
%TabularDatastore   Declares the interface expected of tabular datastores.
%   This class captures the interface expected of tabular datastores. All
%   method calls to READ, PREVIEW and READALL must always return data as a
%   TABULAR (TABLE or TIMETABLE) type. The TABLE returned by the above
%   methods must always have the same variable names and same variable data
%   types for any of the subsequent calls to these methods, after the
%   datastore is setup for reading. For example, in case of
%   TabularTextDatastore, property SelectedVariableNames can be set to a
%   pared down set of VariableNames. After setting this property, it is
%   guaranteed that subsequent calls to PREVIEW, READ and READALL will
%   return a table with the same variable names and variable data types.
%
%   See also matlab.io.datastore.TabularTextDatastore,
%            matlab.io.datastore.SpreadsheetDatastore,
%            matlab.io.datastore.KeyValueDatastore,
%            matlab.io.datastore.DatabaseDatastore, datastore, mapreduce.

%   Copyright 2016 The MathWorks, Inc.

    methods (Abstract, Access = protected)
        %READDATA Read a subset of data into a table or a timetable.
        %   This could very well be the method that reads the data for
        %   the inherited tabular datastores. This method is used by the
        %   read method to check and return a table or a timetable.
        [t, info] = readData(ds);

        %READALLDATA Read all of the data into a table or a timetable.
        %   This could very well be the method that reads all of the data for
        %   the inherited tabular datastores. This method is used by the readall
        %   method to check and return a table or a timetable.
        [t, info] = readAllData(ds);
    end

    methods (Access = protected)
        function t = emptyTabular(ds,variableNames,tabularType)
            %EMPTYTABULAR Create an empty table (or timetable) with apt
            %   VariableNames. In a scenario, where the table (or timetable)
            %   returned by readall is empty, this helper method is used
            %   to return an empty table (or timetable) with appropriate
            %   VariableNames from the readallData method of concrete subclasses.
            narginchk(1,3);

            switch(nargin)
                case 1
                    % return an empty table without VariableNames
                    t = table.empty(0,0);
                    variableNames = {};
                case 2
                    % return an empty table with VariableNames if specified
                    % as the second arguement to this function.
                    t = table.empty(0,size(variableNames,2));
                case 3
                    % determine the type of function call from the third
                    % argument to this function, 'table' will return an
                    % empty table with VariableNames set with the second
                    % argument, and 'timetable' will return an empty
                    % timetable with VariableNames set with the second
                    % argument.
                    validStr = validatestring(tabularType,{'table','timetable'});
                    switch validStr
                        case 'table'
                            % return an empty table with VariableNames
                            t = table.empty(0,size(variableNames,2));
                        case 'timetable'
                            % return an empty timetable with VariableNames
                            t = timetable.empty(0,size(variableNames,2));
                    end
            end
            t.Properties.VariableNames = variableNames;
        end
    end

    methods (Hidden)
        function info = getTableInfo(ds)
            %GETTABLEINFO Get table information using preview method of datastore.
            %   This method uses preview method of the datastore to obtain
            %   table data and obtain variable names and data types of the variables
            %   to be read by the data. This in fact, enforces the preview method
            %   to return a table or a timetable.

            t = preview(ds);
            if ~isa(t, 'tabular')
                error(message('MATLAB:datastoreio:tabulardatastore:invalidTableOutput', 'preview'));
            end
            info.FirstRow = t(1,:);
            info.VariableNames = t.Properties.VariableNames;
            info.VariableTypes = varfun(@class, info.FirstRow, 'OutputFormat', 'cell');
        end
    end

    methods (Sealed)
        function [t, info] = read(ds)
            %READ   Read subset of data and information about the extracted data.
            %   The read function returns a subset of data from the datastore. The
            %   size of the subset is determined by the size specified by the
            %   datastore properties. On the first call, read function starts reading
            %   from the beginning of the datastore and subsequent calls to the read
            %   function continue reading from the endpoint of the previous call.
            %
            %   DATA = read(DS) reads a subset of data from DS. DATA is a table or a
            %   timetable with variables determined by the properties of datastore DS.
            %   Number of rows in DATA is determined by the read size of the datastore DS.
            %   For more information see the documentation for your datastore type.
            %
            %   [DATA,INFO] = read(DS) also returns a structure array INFO, which
            %   contains information about the data that was read. The exact fields
            %   in INFO depend on the type of your datastore. For instance,
            %   for a TabularTextDatastore, INFO.NumCharactersRead contains the numbers
            %   of characters read. For a SpreadsheetDatastore, INFO.SheetNames contains
            %   the names of the sheets read. For more information on fields of the INFO
            %   structure, see the documentation for your datastore type.
            %
            %   read(DS) errors if there is no more data in DS, and should be used with
            %   hasdata(DS).
            %
            %   See also datastore, hasdata, readall, preview, reset.

            [t, info] = readData(ds);
            if ~isa(t, 'tabular')
                error(message('MATLAB:datastoreio:tabulardatastore:invalidTableOutput', 'readData'));
            end
        end

        function t = readall(ds)
            %READALL   Read all of the data from the datastore.
            %   DATA = READALL(DS) reads all of the data from the datastore DS. DATA is a table
            %   or a timetable with variables governed by the datastore DS. For more information
            %   see the documentation for your datastore type.
            %
            %   See also datastore, read, hasdata, preview, reset.

            t = readAllData(ds);
            if ~isa(t, 'tabular')
                error(message('MATLAB:datastoreio:tabulardatastore:invalidTableOutput', 'readAllData'));
            end
        end
    end
end
