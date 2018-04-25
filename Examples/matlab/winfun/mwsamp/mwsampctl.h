#if !defined(AFX_MWSAMPCTL_H__9999DD55_4D4D_11D1_A663_00A0249C4B9F__INCLUDED_)
#define AFX_MWSAMPCTL_H__9999DD55_4D4D_11D1_A663_00A0249C4B9F__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

// MwsampCtl.h : Declaration of the CMwsampCtrl ActiveX Control class.

/////////////////////////////////////////////////////////////////////////////
// CMwsampCtrl : See MwsampCtl.cpp for implementation.

class CMwsampCtrl : public COleControl
{
	DECLARE_DYNCREATE(CMwsampCtrl)

// Constructor
public:
	CMwsampCtrl();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMwsampCtrl)
	public:
	virtual void OnDraw(CDC* pdc, const CRect& rcBounds, const CRect& rcInvalid);
	virtual void DoPropExchange(CPropExchange* pPX);
	virtual void OnResetState();
	//}}AFX_VIRTUAL

// Implementation
protected:
	~CMwsampCtrl();

	DECLARE_OLECREATE_EX(CMwsampCtrl)    // Class factory and guid
	DECLARE_OLETYPELIB(CMwsampCtrl)      // GetTypeInfo
	DECLARE_PROPPAGEIDS(CMwsampCtrl)     // Property page IDs
	DECLARE_OLECTLTYPE(CMwsampCtrl)		// Type name and misc status

// Message maps
	//{{AFX_MSG(CMwsampCtrl)
		// NOTE - ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

// Dispatch maps
	//{{AFX_DISPATCH(CMwsampCtrl)
	CString m_label;
	short m_radius;
	afx_msg void Beep();
	afx_msg void Redraw();
	afx_msg VARIANT GetVariantArray();
	afx_msg LPDISPATCH GetIDispatch();
	afx_msg BSTR GetBSTR();
	afx_msg VARIANT GetI4Array();
	afx_msg VARIANT GetBSTRArray();
	afx_msg long GetI4();
	afx_msg double GetR8();
	afx_msg VARIANT GetR8Array();
	afx_msg void FireClickEvent();
	afx_msg VARIANT GetVariantVector();
	afx_msg VARIANT GetR8Vector();
	afx_msg VARIANT GetI4Vector();
	afx_msg VARIANT SetBSTRArray(const VARIANT FAR& v);
	afx_msg long SetI4(long l);
	afx_msg VARIANT SetI4Vector(const VARIANT FAR& v);
	afx_msg VARIANT SetI4Array(const VARIANT FAR& v);
	afx_msg double SetR8(double d);
	afx_msg VARIANT SetR8Vector(const VARIANT FAR& v);
	afx_msg VARIANT SetR8Array(const VARIANT FAR& v);
	afx_msg BSTR SetBSTR(LPCTSTR b);
	//}}AFX_DISPATCH
	DECLARE_DISPATCH_MAP()

	afx_msg void AboutBox();

// Event maps
	//{{AFX_EVENT(CMwsampCtrl)
	//}}AFX_EVENT
	DECLARE_EVENT_MAP()

// Dispatch and event IDs
public:
	enum {
	//{{AFX_DISP_ID(CMwsampCtrl)
	dispidLabel = 1L,
	dispidRadius = 2L,
	dispidBeep = 3L,
	dispidRedraw = 4L,
	dispidGetVariantArray = 5L,
	dispidGetIDispatch = 6L,
	dispidGetBSTR = 7L,
	dispidGetI4Array = 8L,
	dispidGetBSTRArray = 9L,
	dispidGetI4 = 10L,
	dispidGetR8 = 11L,
	dispidGetR8Array = 12L,
	dispidFireClickEvent = 13L,
	dispidGetVariantVector = 14L,
	dispidGetR8Vector = 15L,
	dispidGetI4Vector = 16L,
	dispidSetBSTRArray = 17L,
	dispidSetI4 = 18L,
	dispidSetI4Vector = 19L,
	dispidSetI4Array = 20L,
	dispidSetR8 = 21L,
	dispidSetR8Vector = 22L,
	dispidSetR8Array = 23L,
	dispidSetBSTR = 24L,
	//}}AFX_DISP_ID
	};
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MWSAMPCTL_H__9999DD55_4D4D_11D1_A663_00A0249C4B9F__INCLUDED)
