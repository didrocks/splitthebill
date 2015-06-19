import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2

/* Different episods:
  - project creation, explaining the template, run/deploy on the phone
  - base layout, grid units, size for phone
  - using icons (for +/-)
  - protecting your input (validator)
  - how bindings works (advanced bindings)
  - add input methods (as it won't show keyboard) + tricks
    https://developer.ubuntu.com/en/apps/qml/tutorials/ubuntu-screen-keyboard-tricks/
  - factorize components in other files and define API
  - responsive design, portrait mode
  - add currency converter (+ fetching from the web)
  - what happen if the app is or become offline or server doesn't respond?
  - state saver
  - share (email/twitter)
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
            id: main
            spacing: units.gu(1)
            anchors {
                margins: units.gu(2)
                top: parent.top
                left: parent.left
                right: parent.right
            }

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

            /* TODO: add the date only on the archive segment (but before localization) */
            Label {
                id: dateTime
                text: new Date().toLocaleDateString(Qt.locale())
                fontSize: "large"
            }

            // normal Row and not RowLayout as we want to not spawn the entire range
            Row {
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
                }
                Label {
                    text: "$"
                    verticalAlignment: Text.AlignVCenter
                    height: parent.height
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
                }
                Label {
                    id: labelValueSlider
                    text: tipSlider.value.toFixed() + "%"
                    verticalAlignment: Text.AlignVCenter
                    font.weight: Font.Light
                    height: parent.height
                }
            }

            // TODO: add additional top spacing if possible in a nicer way?
            Item {
                height: units.gu(2)
            }

            RowLayout {
                id: totalPay
                height: units.gu(5)
                width: parent.width

                property double initialBill: {
                    if (billPrice.text === "")
                        // first return 0.0, then return placeholderText
                        return parseFloat(billPrice.placeholderText.replace(',', '.'))
                    return parseFloat(billPrice.text.replace(',', '.'));
                }
                property double tip: initialBill * tipSlider.value / 100
                property double bill: initialBill + tip

                RowLayout {
                    Layout.preferredWidth: parent.width / 2
                    Label {
                        text: "Total:"
                    }
                    Label {
                        text: main.displayNum(totalPay.bill) + " $"
                    }
                }
                Label {
                    Layout.preferredWidth: parent.width / 2
                    text: "(incl. tip: " + main.displayNum(totalPay.tip) + " $)"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            RowLayout {
                id: sharePay
                height: units.gu(5)
                width: parent.width

                // TODO: add internal padding (not affecting anchors)
                property double percentage: numPeoplePay.currentValue / parseInt(numPeople.text)

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
                        text: main.displayNum(sharePay.percentage * totalPay.bill) + " $"
                        font.pixelSize: units.gu(2)
                        font.weight: Font.Bold
                    }
                }
                Label {
                    Layout.preferredWidth: parent.width / 2
                    text: "(incl. tip: " + main.displayNum(sharePay.percentage * totalPay.tip) + " $)"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}

