function success = showPropertyHelp(classname,propname)
    helpview_args = helpUtils.reference.getHelpviewArgs(classname,propname);
    if ~isempty(helpview_args)
        helpview(helpview_args{:});
        success = 1;
    else
        success = 0;
    end
end

