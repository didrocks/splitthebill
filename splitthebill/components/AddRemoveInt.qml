import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2

RowLayout {
    spacing: units.gu(1)

    property int min: 0
    property int max: 99
    property alias text: label.text
    property alias currentValue: num.currentValue

    property QtObject modelid
    property string modelPropertyName
    Binding on currentValue { value: modelid[modelPropertyName] }
    Binding {
        target: modelid
        property: modelPropertyName
        value: currentValue
    }

    Label {
        id: label
        verticalAlignment: Text.AlignVCenter
        Layout.fillWidth: true
    }

    // use case: avoid binding loop and interfering with two ways data-binding above
    // good introduced on property changed
    onMaxChanged: { num.currentValue = Math.min(num.currentValue, max) }

    Button {
        iconName: "remove"
        enabled: num.text > min
        onClicked: { num.currentValue-- }
        Layout.maximumWidth: height
    }

    TextField {
        id: num
        Layout.preferredWidth: units.gu(5)
        horizontalAlignment: TextInput.AlignHCenter

        text: currentValue
        // maybe use this as a good example of erased databinding?
        // property int currentValue: { Math.min(num.currentValue, max)}
        property int currentValue
        maximumLength: 2
        readOnly: true
    }

    Button {
        iconName: "add"
        Layout.maximumWidth: height
        enabled: num.text < max
        onClicked: { num.currentValue++ }
    }
}
