import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Themes.Ambiance 1.0

import "components"

/* Different episods:
  - project creation, explaining the template, run/deploy on the phone. Change the locale to en_US.
  - base layout, grid units, size for phone
  - using icons (for +/-), with first, mistakes in the addition (no relation between numPeoplePay and numTotalPeople)
  - protecting your input (validator)
  - how bindings works (advanced bindings)
  - add input methods (as it won't show keyboard) + tricks
    https://developer.ubuntu.com/en/apps/qml/tutorials/ubuntu-screen-keyboard-tricks/
  - factorize components in other files and define API: first non visual element like Bill, then AddRemoveInt
  - more refactoring with the results elements and conditions (like only the orange box for results)
  - state saver (using Bill), app lifecycle management
    -> insist on avoiding the statesaver breaking data-binding when restoring
  - Add 2 ways databindings to be able to store values on both side + redefining defaults and how to change a value
    afterwards.
  - Storing values in u1db
  - add styling like the TextField
  - responsive design, portrait mode
  - add currency converter (+ fetching from the web)
  - what happen if the app is or become offline or server doesn't respond?
  - share (email/twitter)
  - add i18n
  - changing theme
  - save and archive: add Top (textinput + date) and notes at the bottom to be saved
  - add flickable + page stacks…
  - change date, pick up calendar/time
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
            id: model

            // defining default values (but still holding 2 ways databindings)
            // then, removed and moved reset()
            /*numSharePeople: 1
            numTotalPeople: 2
            tipShare: 15
            date: new Date()*/
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
                text: model.title
                placeholderText: "New bill split"
                font.pixelSize: units.gu(3)
                // FIXME: use new styling rules (and don't import old)
                style: TextFieldStyle {
                    background: Item {}
                    color: UbuntuColors.lightAubergine
                    frameSpacing: 0
                    overlaySpacing: 0
                }
                Binding on text { value: model.title }
                Binding {
                    target: model
                    property: "title"
                    value: billName.text
                }
                StateSaver.properties: "text"
            }

            /* TODO: add the date only on the archive segment (but before localization) */
            Label {
                id: dateTime
                text: model.date.toLocaleDateString() + " - " + model.date.toLocaleTimeString()
                font.pixelSize: units.gu(1.5)
            }

            ThinDivider {}

            RowLayout {
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
                    Layout.maximumWidth: units.gu(13)
                    //focus: true -> doesn't work?
                    Component.onCompleted: billPrice.forceActiveFocus()
                    // show first the expanded binding syntax, then the reduced one
                    Binding on text { value: model.rawBill }
                    Binding {
                        target: model
                        property: "rawBill"
                        value: billPrice.text
                        when: billPrice.text !== ""
                    }

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
                Layout.preferredWidth: parent.width
                Layout.maximumWidth: parent.width
                text: "Number of people:"
                min: 1
                // factorize the databinding inside the factorized object
                modelid: model
                modelPropertyName: "numTotalPeople"
                StateSaver.properties: "currentValue"
            }

            AddRemoveInt {
                id: numPeoplePay
                Layout.preferredWidth: parent.width
                Layout.maximumWidth: parent.width
                text: "You pay for:"
                min: 1
                max: numPeople.currentValue
                modelid: model
                modelPropertyName: "numSharePeople"
                StateSaver.properties: "currentValue"
            }

            RowLayout {
                id: tipRow
                spacing: units.gu(1)
                Layout.maximumWidth: parent.width
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
                    live: true
                    Layout.fillWidth: true
                    // for the 2 way databindings episod. Changing the slider breaks the databinding + changing a value
                    // through script and see that it breaks with:
                    // value: model.tipeShare
                    // So, then, use double Binding. Show first the expanded binding notation then the reduced one
                    Binding on value { value: model.tipShare }
                    Binding {
                        target: model
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
                    height: parent.height
                }
            }

            ThinDivider {}

            Total {
                label: "Total:"
                mainValue: model.totalBill
                tipValue: model.totalTip
            }

            Total {
                hilight: true
                label: "You pay:"
                mainValue: model.shareBill
                tipValue: model.shareTip
            }

            Item {

                width: parent.width

                Button {
                    Layout.minimumWidth: units.gu(15)
                    text: "Reset"
                    color: UbuntuColors.red
                    onClicked: model.reset()
                    /* enable to show anchors */
                    anchors.left: parent.left
                }

                /* test for restoring from the model without breaking the 2 way databinding */
                Button {
                    // FIXME: adding an icon expand way more than just the icon size. Is this wanted?
                    //iconName: "add"
                    Layout.minimumWidth: units.gu(15)
                    text: "Archive"
                    color: UbuntuColors.green
                    onClicked: {
                        console.log(JSON.stringify(model.tojson()));
                    }
                    anchors.right: parent.right
                }
            }

        }
    }
}

