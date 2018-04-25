%  Copyright 2016 The MathWorks, Inc.
function showHelpPreferences()    
    locale = java.util.Locale.getDefault; 
    cloader = java.lang.ClassLoader.getSystemClassLoader; 
    bundle = java.util.ResourceBundle.getBundle('com.mathworks.mlwidgets.prefs.resources.RES_Prefs', locale, cloader); 
    preferences(bundle.getString('area.help'));   
end