import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2

/* Different episods:
  - project creation, explaining the template, run/deploy on the phone
  - base layout, grid units, size for phone
  - using icons (for +/-)
  - protecting your input (validator)
  - add input methods (as it won't show keyboard) + tricks
    https://developer.ubuntu.com/en/apps/qml/tutorials/ubuntu-screen-keyboard-tricks/
  - factorize components in other files and define API
  - responsive design, portrait mode
  - add currency converter (+ fetching from the web)
  - what happen if the app is or become offline or server doesn't respond?
  - state saver
  - add i18n
  - changing theme
*/

MainView {
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
        title: "Split the bill"

        ColumnLayout {
            spacing: units.gu(1)
            anchors {
                margins: units.gu(2)
                top: parent.top
                left: parent.left
                right: parent.right
            }

            RowLayout {
                spacing: units.gu(1)

                Label {
                    text: "Bill:"
                    verticalAlignment: Text.AlignVCenter
                    height: parent.height
                }
                TextField {
                    // TODO: click should select the whole item
                    id: billPrice
                    text: '0' + Qt.locale().decimalPoint + '0'
                    errorHighlight: true
                    validator: DoubleValidator {}
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    width: units.gu(13)
                    //focus: true -> doesn't work?
                    Component.onCompleted: billPrice.forceActiveFocus()
                    // NOTE for lesson: this adds simple javascript
                    onActiveFocusChanged: {
                        // TODO: test on touch
                        if (activeFocus == true) {
                            selectAll();
                        }
                        else {
                            select(0,0);
                        }
                    }
                }
            }

            Row {
                spacing: units.gu(1)

                Label {
                    text: "Number of people:"
                    verticalAlignment: Text.AlignVCenter
                    height: parent.height
                    width: units.gu(16) // TODO: fix this for i18n and duplication
                }
                Row {
                    Button {
                        iconName: "remove"
                        width: height
                        enabled: numPeople.text > 1
                        onClicked: { numPeople.text = parseInt(numPeople.text) - 1 }
                    }
                    TextField {
                        // TODO: textField size to match content name?
                        id: numPeople
                        horizontalAlignment: TextInput.AlignHCenter
                        text: "2"
                        maximumLength: 2
                        readOnly: true
                        width: units.gu(5)
                    }
                    Button {
                        iconName: "add"
                        width: height
                        onClicked: { numPeople.text = parseInt(numPeople.text) + 1 }
                    }
                }
            }

            Row {
                spacing: units.gu(1)

                Label {
                    text: "You pay for:"
                    verticalAlignment: Text.AlignVCenter
                    height: parent.height
                    width: units.gu(16) // TODO: fix this for i18n and duplication or use elide?
                }
                Row {
                    Button {
                        iconName: "remove"
                        width: height
                        enabled: numPeoplePay.text > 1
                        onClicked: { numPeoplePay.currentValue = parseInt(numPeoplePay.currentValue) - 1 }
                    }
                    TextField {
                        // TODO: textField size to match content name?
                        id: numPeoplePay
                        horizontalAlignment: TextInput.AlignHCenter
                        text: {
                            if (currentValue > numPeople.text)
                                currentValue = numPeople.text
                            return currentValue;
                        }
                        property int currentValue: 1
                        maximumLength: 2
                        readOnly: true
                        width: units.gu(5)
                    }
                    Button {
                        iconName: "add"
                        width: height
                        enabled: numPeoplePay.text < numPeople.text
                        onClicked: { numPeoplePay.currentValue = parseInt(numPeoplePay.currentValue) + 1 }
                    }
                }
            }

            RowLayout {
                spacing: units.gu(1)
                width: parent.width
                Label {
                    //  width: firstRow.width / 4 - firstRow.spacing
                    id: labelSlider
                    text: "Tip"
                    verticalAlignment: Text.AlignVCenter
                    height: parent.height
                }
                Slider {
                    id: tipSlider
                    //function formatValue(v) { return v.toFixed() }
                    minimumValue: 0
                    maximumValue: 30
                    value: 15
                    live: true
                    Layout.fillWidth: true
                }
                Label {
                    id: labelValueSlider
                    text: tipSlider.value.toFixed()
                    verticalAlignment: Text.AlignVCenter
                    font.weight: Font.Light
                    height: parent.height
                }
            }
        }
    }
}

