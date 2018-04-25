classdef UITableView < handle
    %UITableView abstract interface defines how the table controller talks to
    % its view implementation.
    
    properties (Abstract, Access='protected')
        controllerInterface;
        manager;
        document;
        channel;
        viewStrategy;
    end
    
    methods (Abstract)
        
        createViewStrategy(this)

        % setters
        setData(this, value)
        
        setColumnEditable(this, edit)
        
        setColumnFormat(this, formats)
        
        setColumnName(this, columnName)
        
        setRowName(this, rowName)
        
        setBackgroundColor(this, value)
        
        setForegroundColor(this, value)
        
        setFontName(this, value)
        
        setFontSize(this, value)
        
        setFontAngle(this, value)
        
        setFontWeight(this, value)
        
        setColumnWidth(this, columnWidth)
        
        % getters
        docID = getDocument(this)
        
        channelID = getChannel(this)
                
    end
    
end

