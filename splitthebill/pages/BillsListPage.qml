import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2

import "../components"
import "../tools.js" as Tools

PageWithBottomEdge {
    id: billsList
    property QtObject billsHandler

    title: "Split the bill"
    reloadBottomEdgePage: false

    // reset current bottom edge Bill on released
    onBottomEdgeDismissed: { billsHandler.current.reset(); }

    // don't show elements under the header
    clip: true

    /* change current page */
    function editBill(index) {
        billsHandler.current.loadFromJson(currentmodel.get(index));
        mainview.editCurrentBill();
    }

    // the design constraints are allowing a maximum of 1 action on leading- and a maximum of
    // 3 actions on trailing side of the ListItem.
    ListItemActions {
        id: leading
        actions: [
            Action {
                iconName: "delete"
                onTriggered: billsHandler.deleteBill(currentmodel.get(value)['billId'])
            }
        ]
    }

    ListItemActions {
        id: trailing
        actions: [
            Action {
                iconName: "share"
            },
            Action {
                iconName: "edit"
                onTriggered: editBill(value)
            }
        ]
    }

    /*
     * we only filter on the name element as u1db nor filtermodel enable to filter on multiple elements with "or".
     * Future tuts on C++ to filter this model?
     * TODO: open a bug on this
     */
    SortFilterModel {
        id: currentmodel
        model: billsHandler.billsResults
        sort.property: "billId"
        sort.order: Qt.DescendingOrder
        // TODO: bug to open: doesn't filter on subproperty like contents.title
        // this seems ot be linked to https://code.launchpad.net/~kalikiana/u1db-qt/indexRoles/+merge/211771
        //filter.property: 'contents.title'
        //filter.pattern: /BAR/
        //-> Using ListModel and Repeater meanwhile
    }

    UbuntuListView {
        id: listview
        height: parent.height
        anchors {
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
            left: parent.left
            right: parent.right
        }

        model: currentmodel
        delegate: BillListItem {
            leadingActions: leading
            trailingActions: trailing
        }
    }

    Item {
        anchors.fill: parent
        visible: billsHandler.all.results.length === 0

        Icon {
            id: emptyStateIcon
            anchors.fill: parent
            anchors.horizontalCenter: emptyStateLabel.horizontalCenter
            opacity: 0.3
            name: "notebook"
        }

        Label {
            id: emptyStateLabel
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            text: "No bills have been archived"
            color: "#5d5d5d"
            fontSize: "x-large"
            wrapMode: Text.WordWrap
        }
    }

    bottomEdgeTitle: "Add new"
    bottomEdgePageComponent: BillEditPage {
        id: billEditPage
        title: billsHandler.current.billId ? "Edit bill" : "New bill"
        billsHandler: billsList.billsHandler
    }
}
