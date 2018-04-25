function service = getDesktopAppCompileService()
%GETDESKTOPAPPCOMPILESERVICE function to return the ApplicationCompilerService.
%
%This is a separate standalone function to allow us the opportunity to
%differentiate between calls to compile for destop vs. web
    service = com.mathworks.toolbox.compiler.services.ApplicationCompilerService;
end