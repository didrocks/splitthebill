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
    components/BillData.qml

#specify where the qml/js files are installed to
qml_files.path = /splitthebill
qml_files.files += $${QML_FILES}

#specify where the config files are installed to
config_files.path = /splitthebill
config_files.files += $${CONF_FILES}

INSTALLS+=config_files qml_files

