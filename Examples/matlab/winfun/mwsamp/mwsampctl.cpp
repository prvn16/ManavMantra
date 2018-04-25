// MwsampCtl.cpp : Implementation of the CMwsampCtrl ActiveX Control class.

#include "stdafx.h"
#include "mwsamp.h"
#include "MwsampCtl.h"
#include "MwsampPpg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


IMPLEMENT_DYNCREATE(CMwsampCtrl, COleControl)


/////////////////////////////////////////////////////////////////////////////
// Message map

BEGIN_MESSAGE_MAP(CMwsampCtrl, COleControl)
	//{{AFX_MSG_MAP(CMwsampCtrl)
	// NOTE - ClassWizard will add and remove message map entries
	//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG_MAP
	ON_OLEVERB(AFX_IDS_VERB_PROPERTIES, OnProperties)
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// Dispatch map

BEGIN_DISPATCH_MAP(CMwsampCtrl, COleControl)
	//{{AFX_DISPATCH_MAP(CMwsampCtrl)
	DISP_PROPERTY(CMwsampCtrl, "Label", m_label, VT_BSTR)
	DISP_PROPERTY(CMwsampCtrl, "Radius", m_radius, VT_I2)
	DISP_FUNCTION(CMwsampCtrl, "Beep", Beep, VT_EMPTY, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "Redraw", Redraw, VT_EMPTY, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "GetVariantArray", GetVariantArray, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "GetIDispatch", GetIDispatch, VT_DISPATCH, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "GetBSTR", GetBSTR, VT_BSTR, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "GetI4Array", GetI4Array, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "GetBSTRArray", GetBSTRArray, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "GetI4", GetI4, VT_I4, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "GetR8", GetR8, VT_R8, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "GetR8Array", GetR8Array, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "FireClickEvent", FireClickEvent, VT_EMPTY, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "GetVariantVector", GetVariantVector, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "GetR8Vector", GetR8Vector, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "GetI4Vector", GetI4Vector, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsampCtrl, "SetBSTRArray", SetBSTRArray, VT_VARIANT, VTS_VARIANT)
	DISP_FUNCTION(CMwsampCtrl, "SetI4", SetI4, VT_I4, VTS_I4)
	DISP_FUNCTION(CMwsampCtrl, "SetI4Vector", SetI4Vector, VT_VARIANT, VTS_VARIANT)
	DISP_FUNCTION(CMwsampCtrl, "SetI4Array", SetI4Array, VT_VARIANT, VTS_VARIANT)
	DISP_FUNCTION(CMwsampCtrl, "SetR8", SetR8, VT_R8, VTS_R8)
	DISP_FUNCTION(CMwsampCtrl, "SetR8Vector", SetR8Vector, VT_VARIANT, VTS_VARIANT)
	DISP_FUNCTION(CMwsampCtrl, "SetR8Array", SetR8Array, VT_VARIANT, VTS_VARIANT)
	DISP_FUNCTION(CMwsampCtrl, "SetBSTR", SetBSTR, VT_BSTR, VTS_BSTR)
	//}}AFX_DISPATCH_MAP
	DISP_FUNCTION_ID(CMwsampCtrl, "AboutBox", DISPID_ABOUTBOX, AboutBox, VT_EMPTY, VTS_NONE)
END_DISPATCH_MAP()


/////////////////////////////////////////////////////////////////////////////
// Event map

BEGIN_EVENT_MAP(CMwsampCtrl, COleControl)
	//{{AFX_EVENT_MAP(CMwsampCtrl)
	EVENT_STOCK_CLICK()
	//}}AFX_EVENT_MAP
END_EVENT_MAP()


/////////////////////////////////////////////////////////////////////////////
// Property pages

// TODO: Add more property pages as needed.  Remember to increase the count!
BEGIN_PROPPAGEIDS(CMwsampCtrl, 1)
	PROPPAGEID(CMwsampPropPage::guid)
END_PROPPAGEIDS(CMwsampCtrl)


/////////////////////////////////////////////////////////////////////////////
// Initialize class factory and guid

IMPLEMENT_OLECREATE_EX(CMwsampCtrl, "MWSAMP.MwsampCtrl.1",
	0x9999dd47, 0x4d4d, 0x11d1, 0xa6, 0x63, 0, 0xa0, 0x24, 0x9c, 0x4b, 0x9f)


/////////////////////////////////////////////////////////////////////////////
// Type library ID and version

IMPLEMENT_OLETYPELIB(CMwsampCtrl, _tlid, _wVerMajor, _wVerMinor)


/////////////////////////////////////////////////////////////////////////////
// Interface IDs

const IID BASED_CODE IID_DMwsamp =
		{ 0x9999dd45, 0x4d4d, 0x11d1, { 0xa6, 0x63, 0, 0xa0, 0x24, 0x9c, 0x4b, 0x9f } };
const IID BASED_CODE IID_DMwsampEvents =
		{ 0x9999dd46, 0x4d4d, 0x11d1, { 0xa6, 0x63, 0, 0xa0, 0x24, 0x9c, 0x4b, 0x9f } };


/////////////////////////////////////////////////////////////////////////////
// Control type information

static const DWORD BASED_CODE _dwMwsampOleMisc =
	OLEMISC_ACTIVATEWHENVISIBLE |
	OLEMISC_SETCLIENTSITEFIRST |
	OLEMISC_INSIDEOUT |
	OLEMISC_CANTLINKINSIDE |
	OLEMISC_RECOMPOSEONRESIZE;

IMPLEMENT_OLECTLTYPE(CMwsampCtrl, IDS_MWSAMP, _dwMwsampOleMisc)


/////////////////////////////////////////////////////////////////////////////
// CMwsampCtrl::CMwsampCtrlFactory::UpdateRegistry -
// Adds or removes system registry entries for CMwsampCtrl

BOOL CMwsampCtrl::CMwsampCtrlFactory::UpdateRegistry(BOOL bRegister)
{
	// TODO: Verify that your control follows apartment-model threading rules.
	// Refer to MFC TechNote 64 for more information.
	// If your control does not conform to the apartment-model rules, then
	// you must modify the code below, changing the 6th parameter from
	// afxRegApartmentThreading to 0.

	if (bRegister)
		return AfxOleRegisterControlClass(
			AfxGetInstanceHandle(),
			m_clsid,
			m_lpszProgID,
			IDS_MWSAMP,
			IDB_MWSAMP,
			afxRegApartmentThreading,
			_dwMwsampOleMisc,
			_tlid,
			_wVerMajor,
			_wVerMinor);
	else
		return AfxOleUnregisterClass(m_clsid, m_lpszProgID);
}


/////////////////////////////////////////////////////////////////////////////
// CMwsampCtrl::CMwsampCtrl - Constructor

CMwsampCtrl::CMwsampCtrl()
{
	InitializeIIDs(&IID_DMwsamp, &IID_DMwsampEvents);
	m_label = "Label";
	m_radius = 20;
}


/////////////////////////////////////////////////////////////////////////////
// CMwsampCtrl::~CMwsampCtrl - Destructor

CMwsampCtrl::~CMwsampCtrl()
{
}


/////////////////////////////////////////////////////////////////////////////
// CMwsampCtrl::OnDraw - Drawing function

void CMwsampCtrl::OnDraw(
			CDC* pdc, const CRect& rcBounds, const CRect& rcInvalid)
{
	int	x1, y1, x2, y2;	
  
	x1 = rcBounds.left + ((rcBounds.right - rcBounds.left) / 2) - m_radius;
	y1 = rcBounds.top + ((rcBounds.bottom - rcBounds.top) / 2) - m_radius;
	x2 = rcBounds.left + ((rcBounds.right - rcBounds.left) / 2) + m_radius;
	y2 = rcBounds.top + ((rcBounds.bottom - rcBounds.top) / 2) + m_radius;
	pdc->FillRect(rcBounds, CBrush::FromHandle((HBRUSH)GetStockObject(WHITE_BRUSH)));
	pdc->Ellipse(x1, y1, x2, y2);
	pdc->TextOut (rcBounds.left, rcBounds.top, m_label );

}


/////////////////////////////////////////////////////////////////////////////
// CMwsampCtrl::DoPropExchange - Persistence support

void CMwsampCtrl::DoPropExchange(CPropExchange* pPX)
{
    ExchangeVersion(pPX, MAKELONG(_wVerMinor, _wVerMajor));
    COleControl::DoPropExchange(pPX);

  // Call PX_ functions for each persistent custom property.

    PX_String (pPX, "Label", m_label, "Label");
    PX_Short (pPX, "Radius", m_radius, 20);
}


/////////////////////////////////////////////////////////////////////////////
// CMwsampCtrl::OnResetState - Reset control to default state

void CMwsampCtrl::OnResetState()
{
	COleControl::OnResetState();  // Resets defaults found in DoPropExchange
}


/////////////////////////////////////////////////////////////////////////////
// CMwsampCtrl::AboutBox - Display an "About" box to the user

void CMwsampCtrl::AboutBox()
{
	CDialog dlgAbout(IDD_ABOUTBOX_MWSAMP);
	dlgAbout.DoModal();
}


/////////////////////////////////////////////////////////////////////////////
// CMwsampCtrl message handlers


void CMwsampCtrl::Beep() 
{
    MessageBeep (0xFFFFFFFF);
}


void CMwsampCtrl::Redraw() 
{
    RedrawWindow();
}


/////////////////////////////////////////////////////////////////////////////
// Force a click event to be fired.
void CMwsampCtrl::FireClickEvent() 
{
    COleControl::FireClick ();
}


/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// Data Conversion test functions

/////////////////////////////////////////////////////////////////////////////
// return a VT_R8
double CMwsampCtrl::GetR8() 
{
    return 27.3;
}


/////////////////////////////////////////////////////////////////////////////
// return a VT_R8 array
VARIANT CMwsampCtrl::GetR8Array() 
{
    VARIANT		vaResult;
    SAFEARRAYBOUND	sab[2];
    SAFEARRAY		*pSA;
    double		*pData;
    // MATLAB and VB use the same array organization, but C uses a different
    // one, so initialize the C data to look the way VB would do it (row major)
    // so we can just memcpy it in below....
    double		pSource[2][3] = {{1.0, 4.0, 2.0}, {5.0, 3.0, 6.0}};

    VariantInit(&vaResult);
    
    sab[0].cElements    = 2;
    sab[0].lLbound      = 0;
    sab[1].cElements    = 3;
    sab[1].lLbound      = 0;

    pSA = SafeArrayCreate (VT_R8, 2, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    memcpy (pData, pSource, sizeof (pSource));
    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_R8 | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;
    return vaResult;
}


/////////////////////////////////////////////////////////////////////////////
// return a BSTR
BSTR CMwsampCtrl::GetBSTR() 
{
    CString strResult("sample string");
    return strResult.AllocSysString();
}


/////////////////////////////////////////////////////////////////////////////
// return a BSTR array
VARIANT CMwsampCtrl::GetBSTRArray() 
{
    VARIANT		vaResult;
    SAFEARRAYBOUND	sab[3];
    SAFEARRAY		*pSA;
    BSTR		*pData;

    VariantInit(&vaResult);
    
    sab[0].cElements    = 2;
    sab[0].lLbound      = 0;
    sab[1].cElements    = 2;
    sab[1].lLbound      = 0;
    sab[2].cElements    = 2;
    sab[2].lLbound      = 0;

    pSA = SafeArrayCreate (VT_BSTR, 3, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    for (int i = 0; i < 2; i++)
    {
	for (int j = 0; j < 2; j++)
	{
	    for (int k = 0; k < 2; k++)
	    {
		BSTR    *pV;
		long    subs[3];
		CString strResult;
		char	p[100];
	    
		subs[0] = i;
		subs[1] = j;
		subs[2] = k;
		SafeArrayPtrOfIndex (pSA, subs, (void **) &pV);

		sprintf (p, "%d %d %d", i + 1, j + 1, k + 1);
		strResult = p;
		*pV = strResult.AllocSysString();
	    }
	}
    }
    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_BSTR | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;
    return vaResult;
}


/////////////////////////////////////////////////////////////////////////////
// return an I4
long CMwsampCtrl::GetI4() 
{
    return 27;
}


/////////////////////////////////////////////////////////////////////////////
// return an I4 array
VARIANT CMwsampCtrl::GetI4Array() 
{
    VARIANT		vaResult;
    SAFEARRAYBOUND	sab[2];
    SAFEARRAY		*pSA;
    int		*pData;
    // MATLAB and VB use the same array organization, but C uses a different
    // one, so initialize the C data to look the way VB would do it (row major)
    // so we can just memcpy it in below....
    int		pSource[2][3] = {{1, 4, 2}, {5, 3, 6}};

    
    VariantInit(&vaResult);
    
    sab[0].cElements    = 2;
    sab[0].lLbound      = 0;
    sab[1].cElements    = 3;
    sab[1].lLbound      = 0;

    pSA = SafeArrayCreate (VT_I4, 2, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    memcpy (pData, pSource, sizeof (pSource));
    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_I4 | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;
    return vaResult;
}


/////////////////////////////////////////////////////////////////////////////
// return an IDispatch
LPDISPATCH CMwsampCtrl::GetIDispatch() 
{
    return (COleControl::GetIDispatch (TRUE));
}


/////////////////////////////////////////////////////////////////////////////
// sample routine which returns a variant which contains an array of
// variants, each of which is a double or a string
VARIANT CMwsampCtrl::GetVariantArray() 
{
    VARIANT		vaResult;
    SAFEARRAYBOUND	sab[2];
    SAFEARRAY		*pSA;
    double		*pData;
    double		pSource[2][3] = {{1.0, 2.0, 3.0}, {4.0, 5.0, 6.0}};

    VariantInit(&vaResult);
    
    sab[0].cElements    = 2;
    sab[0].lLbound      = 0;
    sab[1].cElements    = 3;
    sab[1].lLbound      = 0;

    pSA = SafeArrayCreate (VT_VARIANT, 2, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    for (int i = 0; i < 2; i++)
    {
	for (int j = 0; j < 3; j++)
	{
	    VARIANT *pV;
	    long    subs[2];
	    
	    subs[0] = i;
	    subs[1] = j;
	    SafeArrayPtrOfIndex (pSA, subs, (void **) &pV);
	    VariantInit (pV);
	  
	  // mix it up with some BSTR variants and some double variants
	    if (i!=j)
	    {
		V_VT (pV) = VT_R8;
		V_R8 (pV) = pSource[i][j];
	    }
	    else
	    {
		CString strResult;
		char	p[100];

		sprintf (p, "%f", pSource[i][j]);
		strResult = p;
		V_VT (pV) = VT_BSTR;
		V_BSTR (pV) = strResult.AllocSysString();
	    }
	}
    }
    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_VARIANT | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;
    return vaResult;
}



/////////////////////////////////////////////////////////////////////////////
// return a vector of variants
VARIANT CMwsampCtrl::GetVariantVector() 
{
    VARIANT		vaResult;
    SAFEARRAYBOUND	sab[1];
    SAFEARRAY		*pSA;
    double		*pData;
    double		pSource[3] = {1.0, 2.0, 3.0};

    VariantInit(&vaResult);
    
    sab[0].cElements    = 3;
    sab[0].lLbound      = 0;

    pSA = SafeArrayCreate (VT_VARIANT, 1, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    for (int i = 0; i < 3; i++)
    {
        VARIANT *pV;
        long    subs[1];
	    
        subs[0] = i;
        SafeArrayPtrOfIndex (pSA, subs, (void **) &pV);
        VariantInit (pV);
	  
      // mix it up with some BSTR variants and some double variants
    	V_VT (pV) = VT_R8;
    	V_R8 (pV) = pSource[i];
    }

    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_VARIANT | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;
    return vaResult;
}


/////////////////////////////////////////////////////////////////////////////
// return a vector of doubles
VARIANT CMwsampCtrl::GetR8Vector() 
{
    VARIANT		vaResult;
    SAFEARRAYBOUND	sab[1];
    SAFEARRAY		*pSA;
    double		*pData;
    // MATLAB and VB use the same array organization, but C uses a different
    // one, so initialize the C data to look the way VB would do it (row major)
    // so we can just memcpy it in below....
    double		pSource[3] = {1.0, 2.0, 3.0};

    VariantInit(&vaResult);
    
    sab[0].cElements    = 3;
    sab[0].lLbound      = 0;

    pSA = SafeArrayCreate (VT_R8, 1, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    memcpy (pData, pSource, sizeof (pSource));
    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_R8 | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;
    return vaResult;
}


/////////////////////////////////////////////////////////////////////////////
// return a vector of integers
VARIANT CMwsampCtrl::GetI4Vector() 
{
 // vaResult.vt=VT_EMPTY;
 // vaResult.vt=VT_NULL;
 // vaResult.vt=VT_ERROR;
 // vaResult.ulVal=count;

 //  VARIANT	vaResult;
 //  VariantInit(&vaResult);
 //  vaResult.vt=VT_NULL;
 //  return vaResult;

    VARIANT		vaResult;
    SAFEARRAYBOUND	sab[1];
    SAFEARRAY		*pSA;
    int		*pData;
    // MATLAB and VB use the same array organization, but C uses a different
    // one, so initialize the C data to look the way VB would do it (row major)
    // so we can just memcpy it in below....
    int		pSource[3] = {1, 2, 3};

    
    VariantInit(&vaResult);
    
    sab[0].cElements    = 3;
    sab[0].lLbound      = 0;

    pSA = SafeArrayCreate (VT_I4, 1, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    memcpy (pData, pSource, sizeof (pSource));
    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_I4 | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;
    return vaResult;

}



BSTR CMwsampCtrl::SetBSTR(LPCTSTR b) 
{
    CString strResult(b);
    return strResult.AllocSysString();
}


VARIANT CMwsampCtrl::SetBSTRArray(const VARIANT FAR& v) 
{
    VARIANT vaResult;
    VariantInit(&vaResult);
    VariantCopy (&vaResult, (VARIANT *) &v);
    return vaResult;
}

long CMwsampCtrl::SetI4(long l) 
{
    return l;
}

VARIANT CMwsampCtrl::SetI4Vector(const VARIANT FAR& v) 
{
    VARIANT vaResult;
    VariantInit(&vaResult);
    VariantCopy (&vaResult, (VARIANT *) &v);
    return vaResult;
}

VARIANT CMwsampCtrl::SetI4Array(const VARIANT FAR& v) 
{
    VARIANT vaResult;
    VariantInit(&vaResult);
    VariantCopy (&vaResult, (VARIANT *) &v);
    return vaResult;
}

double CMwsampCtrl::SetR8(double d) 
{
    return d;
}

VARIANT CMwsampCtrl::SetR8Vector(const VARIANT FAR& v) 
{
    VARIANT vaResult;
    VariantInit(&vaResult);
    VariantCopy (&vaResult, (VARIANT *) &v);
    return vaResult;
}

VARIANT CMwsampCtrl::SetR8Array(const VARIANT FAR& v) 
{
    VARIANT vaResult;
    VariantInit(&vaResult);
    VariantCopy (&vaResult, (VARIANT *) &v);
    return vaResult;
}

