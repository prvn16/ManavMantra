function propval = getBrushingProp(varName,mfile,fcnname,propName)

h = datamanager.BrushManager.getInstance();
propval = h.getBrushingProp(varName,mfile,fcnname,propName);