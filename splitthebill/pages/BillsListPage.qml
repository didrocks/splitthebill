import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2

import "../components"
import "../components/settings"
import "../tools.js" as Tools

PageWithBottomEdge {
    id: billsListPage
    property QtObject billsHandler

    title: i18n.tr("Split the bill")
    reloadBottomEdgePage: false

    // reset current bottom edge Bill on released
    onBottomEdgeDismissed: billsHandler.current.reset()

    // don't show elements under the header
    clip: true

    /* change current page */
    function editBill(index) {
        billsHandler.current.loadFromJson(currentmodel.get(index));
        showBottomEdgePage();
    }

    state: "default"
    StateSaver.properties: "state"
    states: [
        PageHeadState {
            name: "default"
            head: billsListPage.head
            actions: [
                Action {
                    text: i18n.tr("Search")
                    iconName: "search"
                    visible: !billsHandler.isEmpty
                    onTriggered: {
                        billsListPage.state = "search";
                        textsearch.forceActiveFocus();
                    }
                },
                Action {
                    text: i18n.tr("Settings")
                    iconName: "settings"
                    onTriggered: { mainStack.push(Qt.createComponent("SettingsPage.qml"), {"billsHandler": billsHandler}) }
                }
            ]
        },
        PageHeadState {
            id: pageHeadStateSearch
            name: "search"
            head: billsListPage.head
            backAction: Action {
                text: i18n.tr("Cancel")
                iconName: "back"
                onTriggered: {
                    textsearch.text = "";
                    billsListPage.state = "default";
                    listview.forceActiveFocus();
                }
            }
            contents: TextField {
                id: textsearch
                anchors {
                    left: parent ? parent.left : undefined
                    right: parent ? parent.right: undefined
                    rightMargin: units.gu(2)
                }
                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: i18n.tr("Search…")
                onTextChanged: billsHandler.query = Tools.normalizeNum(text)
                StateSaver.properties: "text"
            }
        }
    ]

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
                onTriggered: {
                    billToShare.loadFromJson(currentmodel.get(value));
                    contentHubHandler.share(billToShare);
                }
            },
            Action {
                iconName: "edit"
                onTriggered: editBill(value)
            }
        ]
    }

    Bill {
        // bill used only for sharing
        id: billToShare
    }

    /*
     * we only filter on the name element as u1db nor filtermodel enable to filter on multiple elements with "or".
     * Future tuts on C++ to filter this model?
     * TODO: open a bug on this
     */
    SortFilterModel {
        id: currentmodel
        model: billsHandler.billsResults
        sort.property: "timestamp"
        sort.order: Qt.DescendingOrder
        // TODO: bug to open: doesn't filter on subproperty like contents.title
        // this seems ot be linked to https://code.launchpad.net/~kalikiana/u1db-qt/indexRoles/+merge/211771
        //filter.property: 'contents.title'
        //filter.pattern: /BAR/
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

        section.property: {
            if (AppSettings.billSeparationType === AppSettings.sSEPARATIONTYPE.month)
                return "monthSection";
            else if (AppSettings.billSeparationType === AppSettings.sSEPARATIONTYPE.year)
                return "yearSection";
            return ""
        }
        section.criteria: ViewSection.FullString
        section.delegate: sectionHeading
    }

    Component {
        id: sectionHeading
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: childrenRect.height
            color: UbuntuColors.warmGrey
            Label {
                anchors.right: parent.right
                text: section
                font.bold: true
                color: "black"
                fontSize: "large"
            }
        }
    }

    ContentHubHandler {
        id: contentHubHandler
    }

    Item {
        anchors.fill: parent
        visible: billsHandler.isEmpty || billsHandler.noResults

        Icon {
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

            /* COMMENT: present translators comment in i18n */
            // TRANSLATORS: Presented when no bills were saved
            text: {
                if (billsHandler.isEmpty)
                    return i18n.tr("No bills have been archived")
                else if (billsHandler.noResults)
                    return i18n.tr("No results for your query")
                return ""
            }
            color: "#5d5d5d"
            fontSize: "x-large"
            wrapMode: Text.WordWrap
        }
    }

    bottomEdgeTitle: "Add new"
    bottomEdgePageComponent: BillEditPage {
        id: billEditPage
        title: billsHandler.current.billId ? i18n.tr("Edit bill") : i18n.tr("New bill")
        billsHandler: billsListPage.billsHandler
    }
}
