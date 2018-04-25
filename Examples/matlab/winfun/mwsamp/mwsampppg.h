#if !defined(AFX_MWSAMPPPG_H__9999DD57_4D4D_11D1_A663_00A0249C4B9F__INCLUDED_)
#define AFX_MWSAMPPPG_H__9999DD57_4D4D_11D1_A663_00A0249C4B9F__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

// MwsampPpg.h : Declaration of the CMwsampPropPage property page class.

////////////////////////////////////////////////////////////////////////////
// CMwsampPropPage : See MwsampPpg.cpp.cpp for implementation.

class CMwsampPropPage : public COlePropertyPage
{
	DECLARE_DYNCREATE(CMwsampPropPage)
	DECLARE_OLECREATE_EX(CMwsampPropPage)

// Constructor
public:
	CMwsampPropPage();

// Dialog Data
	//{{AFX_DATA(CMwsampPropPage)
	enum { IDD = IDD_PROPPAGE_MWSAMP };
		// NOTE - ClassWizard will add data members here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_DATA

// Implementation
protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Message maps
protected:
	//{{AFX_MSG(CMwsampPropPage)
		// NOTE - ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

};

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MWSAMPPPG_H__9999DD57_4D4D_11D1_A663_00A0249C4B9F__INCLUDED)
