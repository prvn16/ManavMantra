function helpview_args = getHelpviewArgs(classname, propname)
    if nargin < 2
        help_topic = classname;
        propname = '[property]';
    else
        help_topic = [classname '.' propname];
    end
    
    helpview_args = {};
    
    % See if we have help provided by the reference API.
    ht = com.mathworks.mlwidgets.help.HelpTopic(help_topic);
    ref_data = ht.getReferenceData;
    if ~isempty(ref_data) && ref_data.size > 0
        helpview_args = {buildHelpPath(ref_data.get(0))};
        return;
    end
    
    % Check for a map file for the class.
    map = com.mathworks.mlwidgets.help.TopicMapLocator.getMapPath(classname);
    if ~isempty(map)
        helpview_args = {['mapkey:' classname], propname ,'CSHelpWindow'};
    end    
end

function helpPath = buildHelpPath(ref_data)
    prod = ref_data.getDocSetItem;
    relPath = ref_data.getRelativePath;
    docConfig = com.mathworks.mlwidgets.help.DocCenterDocConfig.getInstance;
    helpPath = char(docConfig.getDocRoot.buildDocSetItemUrl(prod,relPath));
end
