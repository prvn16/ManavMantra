function has_help = classHasPropertyHelp(classname)
    has_help = ~isempty(helpUtils.reference.getHelpviewArgs(classname));
end

