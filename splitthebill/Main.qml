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
  - factorize components in other files and define API: first non visual element like Bill, then AddRemoveInt
  - more refactoring with the Total elements and conditions (like only the orange box for results)
  - state saver (using Bill), app lifecycle management
    -> insist on avoiding the statesaver breaking data-binding when restoring
  - Add 2 ways databindings to be able to store values on both side + redefining defaults and how to change a value
    afterwards.
  - Storing values in u1db
  - signal example (in Bill) on value changed
  - Page view with PageWithBottomEdge… copy. Then fix the warning and versions
  - Then, talking about community components.
  - action bar (for save and reset?) instead of button <- TODO
  - search view and full view
  - add styling like the TextField
  - responsive design, portrait mode
  - add currency converter (+ fetching from the web)
  - what happen if the app is or become offline or server doesn't respond?
  - share (email/twitter) (loader with like contenthubloader in address-book-app)
  - importing bills
  - add i18n
  - changing theme
  - save and archive: add Top (textinput + date) and notes at the bottom to be saved
  - add page stacks and bottom edge
  - change date, pick up calendar/time
  - upload app to the store, availability
  - adding transitions for removing elements
  - first user experience when the app is empty (show a new bill, and so on)
    introduce Timer thanks to it.
  - adding flickable, animations to switch between sections (look at reboot weather app)
  - animations for expanding listitem content
  - default property?
  - error handling (with popup or small noitification window)
*/


MainView {
    id: mainview
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "splitthebill.didrocks"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    width: units.gu(40)
    height: units.gu(75)

    function editCurrentBill() {
        billsPage.showBottomEdgePage();
    }

    BillsListPage {
        id: billsPage
        billsHandler: billsHandler
    }

    PageStack {
        id: mainStack
        // HACK for bug where bottomEdgePage is going over the top
        onCurrentPageChanged: {
            if (currentPage === billsPage.bottomEdgePage)
                billsPage.bottomEdgePage.y = billsPage.header.height
        }
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
        mainStack.push(billsPage);
        // If there is no document on start, show in new Bill page
        if (billsHandler.all.documents.len === 0)
            newBillTimer.running = true;
    }
}

