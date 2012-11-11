#include "StdAfx.h"
#include "MenuItemSelector.h"

using namespace std;

void MenuItemSelector::SelectMenuPath(const HWND windowHandle, list<const char*>& menuItems)
{
	auto automationElement = AutomationElement::FromHandle(IntPtr(windowHandle));
	auto foundMenuItem = automationElement;

	for(list<const char*>::iterator menuItem = menuItems.begin(); menuItem != menuItems.end(); ++menuItem) {
		foundMenuItem = GetNextMenuItem(foundMenuItem, gcnew String(*menuItem));
	}

	auto invokePattern = dynamic_cast<InvokePattern^>(foundMenuItem->GetCurrentPattern(InvokePattern::Pattern));
	invokePattern->Invoke();
}

PropertyCondition^ MenuItemSelector::NameConditionFor(String^ name)
{
	return gcnew PropertyCondition(AutomationElement::NameProperty, name);
}

AutomationElement^ MenuItemSelector::GetNextMenuItem(AutomationElement^ foundMenuItem, String^ nextMenu)
{
	TryToExpand(AsExpandCollapse(foundMenuItem));
	return foundMenuItem->FindFirst(System::Windows::Automation::TreeScope::Subtree,
								   gcnew AndCondition(MenuItemControlType, NameConditionFor(nextMenu)));
}

ExpandCollapsePattern^ MenuItemSelector::AsExpandCollapse(AutomationElement^ foundMenuItem)
{
	try
	{
		return dynamic_cast<ExpandCollapsePattern^>(foundMenuItem->GetCurrentPattern(ExpandCollapsePattern::Pattern));
	}
	catch(Exception^ e)
	{
		return nullptr;
	}
}

void MenuItemSelector::TryToExpand(ExpandCollapsePattern^ expandCollapsePattern)
{
	if (nullptr == expandCollapsePattern) return;

	try
	{
		expandCollapsePattern->Expand();
	}
	catch(Exception^ e)
	{
		expandCollapsePattern->Expand();
	}
}