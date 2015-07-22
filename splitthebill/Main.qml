import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Themes.Ambiance 1.0

import "components"

/* Different episods:
  - project creation, explaining the template, run/deploy on the phone
  - base layout, grid units, size for phone
  - using icons (for +/-), with first, mistakes in the addition (no relation between numPeoplePay and numTotalPeople)
  - protecting your input (validator)
  - how bindings works (advanced bindings)
  - add input methods (as it won't show keyboard) + tricks
    https://developer.ubuntu.com/en/apps/qml/tutorials/ubuntu-screen-keyboard-tricks/
  - factorize components in other files and define API: first non visual element like Bill, then AddRemoveInt
  - state saver (using Bill), app lifecycle management  - responsive design, portrait mode
    -> insist on avoiding the statesaver breakingb data-binding when restoring
  - add styling like the TextField
  - add currency converter (+ fetching from the web)
  - what happen if the app is or become offline or server doesn't respond?
  - share (email/twitter)
  - add i18n
  - changing theme
  - save and archive: add Top (textinput + date) and notes at the bottom to be saved
  - add flickable + page stacks…
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

    Page {
        id: main
        title: "Split the bill"

        /*
         * explain how to add a javascript function. First use . for everything (C local), then in the 18n, use
         * Qt.local.decimalPoint duplication and then factorize
         */
        /*
         * Display number with 2 digits
         */
        function displayNum(number) {
            number = number.toFixed(2).toString();
            return number.replace(".", Qt.locale().decimalPoint);
        }

        Bill {
            id: bill
            title: billName.text
            bill: {
                // first return placeholderText, then return real text
                if (billPrice.text === "")
                    return parseFloat(billPrice.placeholderText.replace(',', '.'))
                return parseFloat(billPrice.text.replace(',', '.'));
            }

            tipShare: tipSlider.value
            numTotalPeople: numPeople.currentValue
            numSharePeople: numPeoplePay.currentValue
        }

        ColumnLayout {
            id: mainColumn
            spacing: units.gu(1)
            anchors {
                leftMargin: units.gu(2)
                rightMargin: units.gu(2)
                top: parent.top
                left: parent.left
                right: parent.right
            }

            TextField {
                id: billName
                color: UbuntuColors.lightAubergine
                anchors.left: parent.left
                anchors.right: parent.right
                placeholderText: "New bill split"
                font.pixelSize: units.gu(3)
                // FIXME: use new styling rules (and don't import old)
                style: TextFieldStyle {
                    background: Item {}
                    color: UbuntuColors.lightAubergine
                    frameSpacing: 0
                    overlaySpacing: 0
                }
                StateSaver.properties: "text"
            }

            /* TODO: add the date only on the archive segment (but before localization) */
            Label {
                id: dateTime
                text: new Date().toLocaleDateString(Qt.locale())
                font.pixelSize: units.gu(1.5)
            }

            ThinDivider {}

            // normal Row and not RowLayout as we want to not spawn the entire range
            Row {
                id: priceRow
                spacing: units.gu(1)
                anchors.horizontalCenter: parent.horizontalCenter

                Label {
                    text: "Bill:"
                    verticalAlignment: Text.AlignVCenter
                    height: parent.height
                }
                TextField {
                    // TODO: click should select the whole item
                    id: billPrice
                    placeholderText: main.displayNum(0.0)
                    errorHighlight: true
                    validator: DoubleValidator {}
                    maximumLength: 7
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    width: units.gu(13)
                    //focus: true -> doesn't work?
                    Component.onCompleted: billPrice.forceActiveFocus()
                    StateSaver.properties: "text"
                }
                Label {
                    text: "$"
                    verticalAlignment: Text.AlignVCenter
                    height: parent.height
                }
            }

            AddRemoveInt {
                id: numPeople
                text: "Number of people:"
                defaultValue: 2
                min: 1
                StateSaver.properties: "currentValue"
            }

            AddRemoveInt {
                id: numPeoplePay
                text: "You pay for:"
                defaultValue: 1
                min: 1
                max: numPeople.currentValue
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
                    height: parent.height
                }
                Slider {
                    id: tipSlider
                    minimumValue: 0
                    maximumValue: 30
                    value: 15
                    live: true
                    Layout.fillWidth: true
                    StateSaver.properties: "value"
                }
                Label {
                    id: labelValueSlider
                    text: tipSlider.value.toFixed() + "%"
                    verticalAlignment: Text.AlignVCenter
                    font.weight: Font.Light
                    height: parent.height
                }
            }

            ThinDivider {}

            RowLayout {
                height: units.gu(5)
                width: parent.width

                RowLayout {
                    Layout.preferredWidth: parent.width / 2
                    Label {
                        text: "Total:"
                    }
                    Label {
                        text: main.displayNum(bill.totalBill) + " $"
                    }
                }
                Label {
                    Layout.preferredWidth: parent.width / 2
                    text: "(incl. tip: " + main.displayNum(bill.totalTip) + " $)"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            RowLayout {
                height: units.gu(5)
                width: parent.width

                // TODO: add internal padding (not affecting anchors)

                RowLayout {
                    height: parent.height
                    Layout.preferredWidth: parent.width / 2

                    // TODO: UbuntuShape force width == height
                    Rectangle {
                        radius: units.gu(1)
                        gradient: UbuntuColors.orangeGradient
                        anchors {
                            fill: parent
                        }
                    }
                    Label {
                        color: "white"
                        text: "You pay:"
                    }
                    Label {
                        color: UbuntuColors.darkAubergine
                        text: main.displayNum(bill.shareBill) + " $"
                        font.pixelSize: units.gu(2)
                        font.weight: Font.Bold
                    }
                }
                Label {
                    Layout.preferredWidth: parent.width / 2
                    text: "(incl. tip: " + main.displayNum(bill.shareTip) + " $)"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}

