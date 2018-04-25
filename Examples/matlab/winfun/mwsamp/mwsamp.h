#if !defined(AFX_MWSAMP_H__9999DD4D_4D4D_11D1_A663_00A0249C4B9F__INCLUDED_)
#define AFX_MWSAMP_H__9999DD4D_4D4D_11D1_A663_00A0249C4B9F__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

// mwsamp.h : main header file for MWSAMP.DLL

#if !defined( __AFXCTL_H__ )
	#error include 'afxctl.h' before including this file
#endif

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMwsampApp : See mwsamp.cpp for implementation.

class CMwsampApp : public COleControlModule
{
public:
	BOOL InitInstance();
	int ExitInstance();
};

extern const GUID CDECL _tlid;
extern const WORD _wVerMajor;
extern const WORD _wVerMinor;

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MWSAMP_H__9999DD4D_4D4D_11D1_A663_00A0249C4B9F__INCLUDED)
