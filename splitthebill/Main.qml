import QtQuick 2.4
import Ubuntu.Components 1.2

import "components"
import "pages"

/* Different episods:
  - project creation, explaining the template, run/deploy on the phone. Change the locale to en_US.
  - base layout, grid units, size for phone
  - using icons (for +/-), with first, mistakes in the addition (no relation between numPeoplePay and numTotalPeople)
  - protecting your input (validator)
  - how bindings works (advanced bindings)
  - add input methods (as it won't show keyboard) + tricks
    https://developer.ubuntu.com/en/apps/qml/tutorials/ubuntu-screen-keyboard-tricks/
  - factorize components in other files and define API: first non visual element like Bill, then AddRemoveInt.
    How to add subdirectory and edit .pro files
  - more refactoring with the Total elements and conditions (like only the orange box for results)
  - state saver (using Bill), app lifecycle management
    -> insist on avoiding the statesaver breaking data-binding when restoring
  - Add 2 ways databindings to be able to store values on both side + redefining defaults and how to change a value
    afterwards.
  - Storing values in u1db
  - signal example (in Bill) on value changed
  - Page view with PageWithBottomEdge… copy. Then fix the warning and versions
  - Then, talking about community components.
  - action bar (for save and reset?) instead of button
  - search view and full view (introducing states)
  - add styling like the TextField
  - Settings page, store backend settings, singleton and enums
  - when working on listView: add format.arg() concept + changing height + animation on changing height
  - animations for expanding listitem content
  - responsive design, portrait mode
  - add currency converter (+ fetching from the web)
  - // what happen if the app is or become offline or server doesn't respond?
  - share (email/twitter) (loader with like contenthubloader in address-book-app)
  - // importing bills
  - add i18n (show currency, build pot, po and mo files). Also switch order: xxx € for $xxx for instance for currency
    fix it as well for existing module bug.
  - changing theme
  - save and archive: add notes + photo at the bottom to be saved. Ensure to refactor there to only list properties
    to be saved as few as possible
  - change the date with a time + date picker, define new components, explain limits and timezone. Use that to present
    MouseArea as well.
  - add page stacks and bottom edge
  - upload app to the store, availability
  - // adding transitions for removing elements
  - first user experience when the app is empty (show a new bill, and so on)
    introduce Timer thanks to it.
  - adding flickable, animations to switch between sections (look at reboot weather app)
  - error handling (with popup or small notification window)
  - general polish (no search match, focus and so on)
  attachements enables to introduce:
  - contenthub import
  - file management (as we have to remove files). First, with contenthub and listing the directory manually. Then C++
  http://bazaar.launchpad.net/~ubuntu-clock-dev/ubuntu-clock-app/utopic-3.0/view/head:/app/alarm/EditAlarmPage.qml#L197
  - contenthub export to other apps.
  - adding C++ binding: remove files (attachements)
  - worker script (putting the model manipulation in it) after showing it can be slow if done in the UI for fake loops
  - // Animation system (removing one of the attachment)
  - location service addition


  TODO: open a bug that even with permission denied, we always get sourceError as PositionSource.NoError
  TODO: open a bug that even when switching back to permission denied while the app is running, the next refresh still get the location

  TODO: open a bug for the singleton, when imported from the same directory
  TODO: open a bug for the . in the keyboard, not respecting locale and so failing in the validator
*/

MainView {
    id: mainview
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "splitthebill.didrocks"

    width: units.gu(40)
    height: units.gu(75)

    BillsListPage {
        id: billsPage
        billsHandler: billsHandler
    }

    PageStack {
        id: mainStack
        property string lastPage;
        onCurrentPageChanged: {
            // HACK for bug where bottomEdgePage is going over the top
            // TODO: open a bug for this
            if (currentPage === billsPage.bottomEdgePage) {
                lastPage = "bottomEdgePage";
                billsPage.bottomEdgePage.y = billsPage.header.height
                billsPage.bottomEdgePage.activate();
            } else if (currentPage === billsPage)
                lastPage = "main";
            else if (String(currentPage).indexOf("SettingsPage") != -1)
                lastPage = "settings";
            else
                lastPage = currentPage
        }
        StateSaver.properties: "lastPage"
    }

    Bills {
        id: billsHandler
    }

    Timer {
        id: newBillTimer
        interval: 1000 // let 1000ms by default after page pushed
        onTriggered: billsPage.showBottomEdgePage()
    }

    Component.onCompleted: {
        var pageToRestore = mainStack.lastPage;
        mainStack.push(billsPage);
        if (pageToRestore === "bottomEdgePage")
            billsPage.showBottomEdgePage();
        else if (pageToRestore === "settings")
            mainStack.push(Qt.createComponent("pages/SettingsPage.qml"), {"billsHandler": billsHandler});

        // If there is no document on start, show in new Bill page
        if (billsHandler.isEmpty)
            newBillTimer.running = true;
    }
}

