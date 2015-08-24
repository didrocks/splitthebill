TEMPLATE = aux
TARGET = splitthebill

RESOURCES += splitthebill.qrc

QML_FILES += $$files(*.qml,false) \
             $$files(*.js,false)

COMPONENTS_FILES += $$files(components/*.qml,false) \
                    $$files(components/*.js,false)

SETTINGS_FILES += $$files(components/settings/*,false)

PAGES_FILES += $$files(pages/*.qml,false) \
               $$files(pages/*.js,false)

CONF_FILES +=  splitthebill.apparmor \
               splitthebill.desktop \
               splitthebill.png

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES}

#specify where the qml/js files are installed to
qml_files.path = /splitthebill
qml_files.files += $${QML_FILES}

#specify where the config files are installed to
config_files.path = /splitthebill
config_files.files += $${CONF_FILES}

components_files.path = /splitthebill/components
components_files.files += $${COMPONENTS_FILES}

settings_files.path = /splitthebill/components/settings
settings_files.files += $${SETTINGS_FILES}

pages_files.path = /splitthebill/pages
pages_files.files += $${PAGES_FILES}

INSTALLS+=config_files qml_files components_files settings_files pages_files
