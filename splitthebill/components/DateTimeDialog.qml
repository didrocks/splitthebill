import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.Pickers 1.0

Component {

    // picker handler binding loop warning: https://launchpad.net/bugs/1419667
    Dialog {
        id: popover
        property date date: billsHandler.current.date

        DatePicker {
            id: datePicker
            date: popover.date

            onDateChanged: {
                // Need to use an intermediate object: https://launchpad.net/bugs/1482512
                var newDate = new Date(popover.date);
                newDate.setFullYear(date.getFullYear(), date.getMonth(), date.getDate());
                popover.date = newDate;
            }
        }

        DatePicker {
                id: timePicker
                date: popover.date
                mode: "Hours|Minutes"
                onDateChanged: {
                    // Need to use an intermediate object: https://launchpad.net/bugs/1482512
                    var newDate = new Date(popover.date);
                    newDate.setHours(date.getHours(), date.getMinutes());
                    popover.date = newDate;
                }
        }

        Button {
            text: i18n.tr("Close")
            color: UbuntuColors.green
            onClicked: {
                billsHandler.current.date = date;
                PopupUtils.close(popover);
            }
        }
    }
}
