import QtQuick 2.0
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2

RowLayout {

    property bool hilight: false
    property alias label: labelPrefix.text
    property double mainValue
    property double tipValue

    width: parent.width
    Layout.maximumWidth: parent.width
    height: units.gu(5)
    clip: true

    // TODO: UbuntuShape force width == height
    Rectangle {
        radius: units.gu(1)
        gradient: UbuntuColors.orangeGradient
        anchors {
            fill: parent
        }

        // do this first, see that the items are not align, so change the opacity
        //visible: hilight

        // FIXME: this is a bit of a hack, but didn't find any other way to align the 2 "Total" and "You pay" text
        // opacity: if (!hilight) 0, or opacity: if (!hilight) 0 : opacity
        // then, show the assign [undefinied] and then the binding loop and use the Binding
        Binding on opacity {
            when: !hilight
            value: 0
        }
    }

    RowLayout {
        height: parent.height
        Layout.preferredWidth: parent.width / 2
        Layout.maximumWidth: parent.width / 2
        clip: true
        Label {
            id: labelPrefix
            Binding on color {
                when: hilight
                value: "white"
            }
        }
        Text {
            Layout.maximumWidth: parent.width - labelPrefix.width
            Binding on color {
                when: hilight
                value: UbuntuColors.darkAubergine
            }
            Binding on font.pixelSize {
                when: hilight
                value: units.gu(2)
            }
            Binding on font.weight {
                when: hilight
                value: Font.Bold
            }
            text: main.displayNum(mainValue) + " $"
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }
    Text {
        Layout.preferredWidth: parent.width / 2
        Layout.maximumWidth: parent.width / 2
        text: "(incl. tip: " + main.displayNum(tipValue) + " $)"
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }
}
