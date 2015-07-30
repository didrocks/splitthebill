import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Themes.Ambiance 1.0

import "../components"
import "../tools.js" as Tools

Page {
    id: page
    property QtObject billsHandler

    Column {
        id: mainColumn

        spacing: units.gu(1)
        anchors {
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
            // force the column to match page width
            left: parent.left
            right: parent.right
        }

        TextField {
            id: billName
            color: UbuntuColors.lightAubergine
            // use anchors instead of width: parent.width (more performant as don't go to through the binding system)
            anchors { left: parent.left; right: parent.right }
            text: billsHandler.current.title
            placeholderText: "New bill split"
            font.pixelSize: units.gu(3)
            // FIXME: use new styling rules (and don't import old)
            style: TextFieldStyle {
                background: Item {}
                color: UbuntuColors.lightAubergine
                frameSpacing: 0
                overlaySpacing: 0
            }
            Binding on text { value: billsHandler.current.title }
            Binding {
                target: billsHandler.current
                property: "title"
                value: billName.text
            }
            StateSaver.properties: "text"
        }

        /* TODO: add the date only on the archive segment (but before localization) */
        Label {
            id: dateTime
            text: billsHandler.current.date.toLocaleDateString() + " - " + billsHandler.current.date.toLocaleTimeString()
            font.pixelSize: units.gu(1.5)
        }


        Row {
            id: priceRow

            spacing: units.gu(1)
            anchors.horizontalCenter: parent.horizontalCenter

            Label {
                text: "Bill:"
                height: parent.height
                verticalAlignment: Text.AlignVCenter
            }
            TextField {
                // TODO: click should select the whole item
                id: billPrice
                width: units.gu(13)
                placeholderText: Tools.displayNum(0.0)
                errorHighlight: true
                validator: DoubleValidator {}
                maximumLength: 7
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                //focus: true -> doesn't work?
                Component.onCompleted: billPrice.forceActiveFocus()
                // show first the expanded binding syntax, then the reduced one
                Binding on text { value: billsHandler.current.rawBill }
                Binding {
                    target: billsHandler.current
                    property: "rawBill"
                    value: billPrice.text
                    when: billPrice.text !== ""
                }
                StateSaver.properties: "text"
            }
            Label {
                text: "$"
                height: parent.height
                verticalAlignment: Text.AlignVCenter
            }
        }

        AddRemoveInt {
            id: numPeople
            anchors { left: parent.left; right: parent.right }
            text: "Number of people:"
            min: 1
            // factorize the databinding inside the factorized object
            modelid: billsHandler.current
            modelPropertyName: "numTotalPeople"
            StateSaver.properties: "currentValue"
        }

        AddRemoveInt {
            id: numPeoplePay
            anchors { left: parent.left; right: parent.right }
            text: "You pay for:"
            min: 1
            max: numPeople.currentValue
            modelid: billsHandler.current
            modelPropertyName: "numSharePeople"
            StateSaver.properties: "currentValue"
        }

        RowLayout {
            id: tipRow
            spacing: units.gu(1)
            anchors { left: parent.left; right: parent.right }
            Label {
                id: labelSlider
                text: "Tip"
                verticalAlignment: Text.AlignVCenter
            }
            Slider {
                id: tipSlider
                minimumValue: 0
                maximumValue: 30
                live: true
                Layout.fillWidth: true
                // for the 2 way databindings episod. Changing the slider breaks the databinding + changing a value
                // through script and see that it breaks with:
                // value: billsHandler.current.tipeShare (this name is direct binding)
                // So, then, use double Binding. Show first the expanded binding notation then the reduced one
                Binding on value { value: billsHandler.current.tipShare }
                Binding {
                    target: billsHandler.current
                    property: "tipShare"
                    value: tipSlider.value
                }
                StateSaver.properties: "value"
            }
            Label {
                id: labelValueSlider
                text: tipSlider.value.toFixed() + "%"
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.Light
            }
        }

        ThinDivider {}

        Total {
            anchors { left: parent.left; right: parent.right }
            label: "Total:"
            mainValue: billsHandler.current.totalBill
            tipValue: billsHandler.current.totalTip
        }

        Total {
            anchors { left: parent.left; right: parent.right }
            hilight: true
            label: "You pay:"
            mainValue: billsHandler.current.shareBill
            tipValue: billsHandler.current.shareTip
        }

        Item {
            height: childrenRect.height
            anchors { left: parent.left; right: parent.right }

            Button {
                text: "Reset"
                color: UbuntuColors.red
                onClicked: billsHandler.current.reset()
                /* enable to show anchors */
                anchors.left: parent.left
            }

            Button {
                // Bug https://launchpad.net/bugs/1478839: adding the iconName expands way more than just the icon size
                //iconName: "add"
                text: "Archive"
                color: UbuntuColors.green
                onClicked: {
                    //console.log(JSON.stringify(billsHandler.current.tojson()));
                    billsHandler.saveCurrent();
                }
                anchors.right: parent.right
            }
        }
    }
}
