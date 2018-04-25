// MwsampPpg.cpp : Implementation of the CMwsampPropPage property page class.

#include "stdafx.h"
#include "mwsamp.h"
#include "MwsampPpg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


IMPLEMENT_DYNCREATE(CMwsampPropPage, COlePropertyPage)


/////////////////////////////////////////////////////////////////////////////
// Message map

BEGIN_MESSAGE_MAP(CMwsampPropPage, COlePropertyPage)
	//{{AFX_MSG_MAP(CMwsampPropPage)
	// NOTE - ClassWizard will add and remove message map entries
	//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// Initialize class factory and guid

IMPLEMENT_OLECREATE_EX(CMwsampPropPage, "MWSAMP.MwsampPropPage.1",
	0x9999dd48, 0x4d4d, 0x11d1, 0xa6, 0x63, 0, 0xa0, 0x24, 0x9c, 0x4b, 0x9f)


/////////////////////////////////////////////////////////////////////////////
// CMwsampPropPage::CMwsampPropPageFactory::UpdateRegistry -
// Adds or removes system registry entries for CMwsampPropPage

BOOL CMwsampPropPage::CMwsampPropPageFactory::UpdateRegistry(BOOL bRegister)
{
	if (bRegister)
		return AfxOleRegisterPropertyPageClass(AfxGetInstanceHandle(),
			m_clsid, IDS_MWSAMP_PPG);
	else
		return AfxOleUnregisterClass(m_clsid, NULL);
}


/////////////////////////////////////////////////////////////////////////////
// CMwsampPropPage::CMwsampPropPage - Constructor

CMwsampPropPage::CMwsampPropPage() :
	COlePropertyPage(IDD, IDS_MWSAMP_PPG_CAPTION)
{
	//{{AFX_DATA_INIT(CMwsampPropPage)
	// NOTE: ClassWizard will add member initialization here
	//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_DATA_INIT
}


/////////////////////////////////////////////////////////////////////////////
// CMwsampPropPage::DoDataExchange - Moves data between page and properties

void CMwsampPropPage::DoDataExchange(CDataExchange* pDX)
{
	//{{AFX_DATA_MAP(CMwsampPropPage)
	// NOTE: ClassWizard will add DDP, DDX, and DDV calls here
	//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_DATA_MAP
	DDP_PostProcessing(pDX);
}


/////////////////////////////////////////////////////////////////////////////
// CMwsampPropPage message handlers
