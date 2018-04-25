function has_help = propertyHasHelp(classname,propname)
    has_help = ~isempty(helpUtils.reference.getHelpviewArgs(classname,propname));
end

