TEMPLATE = aux
TARGET = splitthebill

RESOURCES += splitthebill.qrc

QML_FILES += $$files(*.qml,true) \
					   $$files(*.js,true)

CONF_FILES +=  splitthebill.apparmor \
               splitthebill.desktop \
               splitthebill.png

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
    components/AddRemoveInt.qml \
    components/Bills.qml \
    components/Bill.qml \
    components/Total.qml \
    components/BillListItem.qml \
    tools.js \
    pages/BillsListPage.qml \
    components/PageWithBottomEdge.qml \
    pages/BillEditPage.qml \
    pages/SettingsPage.qml \
    components/AppSettings.qml \
    components/ErrorDialog.qml \
    components/DateTimeDialog.qml \
    components/NewListModel.qml \
    components/ContentHubImport.qml \
    components/ContentHubOut.qml

#specify where the qml/js files are installed to
qml_files.path = /splitthebill
qml_files.files += $${QML_FILES}

#specify where the config files are installed to
config_files.path = /splitthebill
config_files.files += $${CONF_FILES}

INSTALLS+=config_files qml_files

