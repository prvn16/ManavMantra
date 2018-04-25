function link = createMatlabLink(command, linkTarget, linkText)
    link = ['<a href="matlab:' helpUtils.makeDualCommand(command, linkTarget) '">' linkText '</a>'];
end