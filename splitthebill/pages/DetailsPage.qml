import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Themes.Ambiance 1.0

import "../components"
import "../tools.js" as Tools

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
        // we want to expand on full Column width (ZSOMBI: the height is set based on children TextField is not a layout element?)
        width: parent.width
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
        // ZSOMBI: same, no height set, same reasonning than for TextField?
        id: dateTime
        text: billsHandler.current.date.toLocaleDateString() + " - " + billsHandler.current.date.toLocaleTimeString()
        font.pixelSize: units.gu(1.5)
    }

    ThinDivider {} // ZSOMBI: I guess the height is hardcoded in ThinDivider?

    RowLayout {
        id: priceRow
        spacing: units.gu(1)
        anchors.horizontalCenter: parent.horizontalCenter

        // ZSOMBI: I didn't set any Height to any children, so, how the height is set based on children? I thought
        // you had to set it explicitely for positioner?

        Label {
            text: "Bill:"
            verticalAlignment: Text.AlignVCenter
        }
        TextField {
            // TODO: click should select the whole item
            id: billPrice
            placeholderText: Tools.displayNum(0.0)
            errorHighlight: true
            validator: DoubleValidator {}
            maximumLength: 7
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            Layout.maximumWidth: units.gu(13)
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
            verticalAlignment: Text.AlignVCenter
        }
    }

    AddRemoveInt {
        id: numPeople
        // ZSOMBI: none of the children element have an height, the height is set thanks to the label/button?
        // so, that means that the height of this RowLayout is implicit set by the max(children.width)?
        width: parent.width
        text: "Number of people:"
        min: 1
        // factorize the databinding inside the factorized object
        modelid: billsHandler.current
        modelPropertyName: "numTotalPeople"
        StateSaver.properties: "currentValue"
    }

    AddRemoveInt {
        id: numPeoplePay
        width: parent.width
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
        width: parent.width
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
        width: parent.width
        label: "Total:"
        mainValue: billsHandler.current.totalBill
        tipValue: billsHandler.current.totalTip
    }

    Total {
        width: parent.width
        hilight: true
        label: "You pay:"
        mainValue: billsHandler.current.shareBill
        tipValue: billsHandler.current.shareTip
    }

    Item {
        // ZSOMBI: I guess we need to set a height to this one because it's not a positioner nor a Layout
        // like RowLayout, so it doesn't get any implicitHeight from its children
        height: childrenRect.height
        width: parent.width

        Button {
            text: "Reset"
            color: UbuntuColors.red
            onClicked: billsHandler.current.reset()
            /* enable to show anchors */
            anchors.left: parent.left
        }

        Button {
            // ZSOMBI: adding the iconName expands way more than just the icon size. Is this wanted?
            //iconName: "add"
            text: "Archive"
            color: UbuntuColors.green
            onClicked: {
                //console.log(JSON.stringify(billsHandler.current.tojson()));
                billsHandler.refreshCurrent();
            }
            anchors.right: parent.right
        }
    }
}
