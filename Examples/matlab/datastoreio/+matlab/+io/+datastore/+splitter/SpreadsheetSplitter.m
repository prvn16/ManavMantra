classdef SpreadsheetSplitter < matlab.io.datastore.splitter.FileSizeBasedSplitter
%SPREADSHEETSPLITTER Class for creating splits from spreadsheet files

%   Copyright 2015 The MathWorks, Inc.

properties(Constant, Access = 'private')
    SPLIT_SIZE = Inf;
end


methods (Static)
    function this = create(files, fileSizes)
    %CREATE Create a SpreadsheetSplitter.
    
        % imports
        import matlab.io.datastore.splitter.FileSizeBasedSplitter;
        import matlab.io.datastore.splitter.SpreadsheetSplitter;
        
        narginchk(1,2);
        
        if nargin < 2
            fileSizes = [];
        end
        
        % get FileSizeBasedSplitter constructor args
        splits = FileSizeBasedSplitter.createArgs(files, ...
                                           SpreadsheetSplitter.SPLIT_SIZE, fileSizes);
        % construct SpreadsheetSplitter
        this = SpreadsheetSplitter(splits);
    end
    
    function this = createFromSplits(splits)
    %CREATEFROMSPLITS Create a SpreadsheetSplitter given existing splits.
    %   This method is usally called from loadobj.
        
        % imports
        import matlab.io.datastore.splitter.FileSizeBasedSplitter;
        import matlab.io.datastore.splitter.SpreadsheetSplitter;
            
        splits = FileSizeBasedSplitter.createFromSplitsArgs(splits);
        this = SpreadsheetSplitter(splits);
    end
end

methods (Access = 'protected')
    function this = SpreadsheetSplitter(splits)
        
        % imports
        import matlab.io.datastore.splitter.FileSizeBasedSplitter;
        import matlab.io.datastore.splitter.SpreadsheetSplitter;
        
        this@matlab.io.datastore.splitter.FileSizeBasedSplitter(splits, ...
                                           SpreadsheetSplitter.SPLIT_SIZE);
    end
end

methods
    function cp = createCopyWithSplits(this, splits)
    %CREATECOPYWITHSPLITS Create Splitter from existing Splits.
    %   Creates a splitter that is identical except for the splits it
    %   contains. Splits passed as input must be of identical in structure
    %   to the splits used by this Spltiter class.    
        cp = copy(this);
        cp.Splits = splits;
    end
    
    function rdr = createReader(this, ii)
    %CREATEREADER Create a reader for the ii-th split.
    
        rdr = matlab.io.datastore.splitreader.SpreadsheetReader;
        rdr.Split = this.Splits(ii);
    end
end
end