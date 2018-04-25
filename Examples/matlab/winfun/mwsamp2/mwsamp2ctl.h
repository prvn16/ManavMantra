/* Copyright 2001 The MathWorks, Inc. */


#if !defined(AFX_MWSAMP2CTL_H__31AE77B1_CD9F_41B0_9ED9_0DD2E1B329F5__INCLUDED_)
#define AFX_MWSAMP2CTL_H__31AE77B1_CD9F_41B0_9ED9_0DD2E1B329F5__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

// Mwsamp2Ctl.h : Declaration of the CMwsamp2Ctrl ActiveX Control class.

/////////////////////////////////////////////////////////////////////////////
// CMwsamp2Ctrl : See Mwsamp2Ctl.cpp for implementation.

class CMwsamp2Ctrl : public COleControl
{
	DECLARE_DYNCREATE(CMwsamp2Ctrl)

// Constructor
public:
	CMwsamp2Ctrl();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMwsamp2Ctrl)
	public:
	virtual void OnDraw(CDC* pdc, const CRect& rcBounds, const CRect& rcInvalid);
	virtual void DoPropExchange(CPropExchange* pPX);
	virtual void OnResetState();
	//}}AFX_VIRTUAL

// Implementation
protected:
	~CMwsamp2Ctrl();

	DECLARE_OLECREATE_EX(CMwsamp2Ctrl)    // Class factory and guid
	DECLARE_OLETYPELIB(CMwsamp2Ctrl)      // GetTypeInfo
	DECLARE_PROPPAGEIDS(CMwsamp2Ctrl)     // Property page IDs
	DECLARE_OLECTLTYPE(CMwsamp2Ctrl)		// Type name and misc status

// Message maps
	//{{AFX_MSG(CMwsamp2Ctrl)
	afx_msg void OnSize(UINT nType, int cx, int cy);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

// Dispatch maps
	//{{AFX_DISPATCH(CMwsamp2Ctrl)
	CString m_label;
	short m_radius;
	afx_msg LPDISPATCH GetRet_IDispatch();
	afx_msg void SetRet_IDispatch(LPDISPATCH newValue);
	afx_msg VARIANT GetRetVarDisp();
	afx_msg void SetRetVarDisp(const VARIANT FAR& newValue);
	afx_msg void Beep();
	afx_msg void FireClickEvent();
	afx_msg BSTR GetBSTR();
	afx_msg VARIANT GetBSTRArray();
	afx_msg long GetI4();
	afx_msg VARIANT GetI4Array();
	afx_msg VARIANT GetI4Vector();
	afx_msg LPDISPATCH GetIDispatch();
	afx_msg double GetR8();
	afx_msg VARIANT GetR8Array();
	afx_msg VARIANT GetR8Vector();
	afx_msg VARIANT GetVariantArray();
	afx_msg VARIANT GetVariantVector();
	afx_msg void Redraw();
	afx_msg BSTR SetBSTR(LPCTSTR b);
	afx_msg VARIANT SetBSTRArray(const VARIANT FAR& v);
	afx_msg long SetI4(long l);
	afx_msg VARIANT SetI4Array(const VARIANT FAR& v);
	afx_msg VARIANT SetI4Vector(const VARIANT FAR& v);
	afx_msg double SetR8(double d);
	afx_msg VARIANT SetR8Array(const VARIANT FAR& v);
	afx_msg VARIANT SetR8Vector(const VARIANT FAR& v);
	afx_msg void FireEventArgs();
	afx_msg double AddDouble(double db1, double db2);
	afx_msg void FireMouseDownEvent();
	afx_msg VARIANT ShowVariant(short arg1, const VARIANT FAR& var1, const VARIANT FAR& var2, const VARIANT FAR& var3, const VARIANT FAR& var4);
	afx_msg VARIANT ReturnVTError();
	afx_msg void Fire_Double_Click();
	afx_msg BOOL SetIDispatch(LPDISPATCH arg1);
	afx_msg BOOL VariantOfTypeHandle(const VARIANT FAR& arg1);
	afx_msg SCODE RetErrorInfo();
	//}}AFX_DISPATCH
	DECLARE_DISPATCH_MAP()

	afx_msg void AboutBox();

// Event maps
	//{{AFX_EVENT(CMwsamp2Ctrl)
	void FireEvent_Args(short typeshort, long typelong, double typedouble, LPCTSTR typestring, BOOL typebool)
		{FireEvent(eventidEvent_Args,EVENT_PARAM(VTS_I2  VTS_I4  VTS_R8  VTS_BSTR  VTS_BOOL), typeshort, typelong, typedouble, typestring, typebool);}
	//}}AFX_EVENT
	DECLARE_EVENT_MAP()

// Dispatch and event IDs
public:
	enum {
	//{{AFX_DISP_ID(CMwsamp2Ctrl)
	dispidLabel = 1L,
	dispidRadius = 2L,
	dispidRet_IDispatch = 3L,
	dispidRetVarDisp = 4L,
	dispidBeep = 5L,
	dispidFireClickEvent = 6L,
	dispidGetBSTR = 7L,
	dispidGetBSTRArray = 8L,
	dispidGetI4 = 9L,
	dispidGetI4Array = 10L,
	dispidGetI4Vector = 11L,
	dispidGetIDispatch = 12L,
	dispidGetR8 = 13L,
	dispidGetR8Array = 14L,
	dispidGetR8Vector = 15L,
	dispidGetVariantArray = 16L,
	dispidGetVariantVector = 17L,
	dispidRedraw = 18L,
	dispidSetBSTR = 19L,
	dispidSetBSTRArray = 20L,
	dispidSetI4 = 21L,
	dispidSetI4Array = 22L,
	dispidSetI4Vector = 23L,
	dispidSetR8 = 24L,
	dispidSetR8Array = 25L,
	dispidSetR8Vector = 26L,
	dispidFireEventArgs = 27L,
	dispidAddDouble = 28L,
	dispidFireMouseDownEvent = 29L,
	dispidShowVariant = 30L,
	dispidReturnVTError = 31L,
	dispidFire_Double_Click = 32L,
	dispidSetIDispatch = 33L,
	dispidVariantOfTypeHandle = 34L,
	dispidRetErrorInfo = 35L,
	eventidEvent_Args = 1L,
	//}}AFX_DISP_ID
	};
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MWSAMP2CTL_H__31AE77B1_CD9F_41B0_9ED9_0DD2E1B329F5__INCLUDED)
