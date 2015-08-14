#include <QtQml>
#include <QtQml/QQmlContext>
#include "backend.h"
#include "attachmentstore.h"


void BackendPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("splitthebill"));

    // add new C++ types to export to QML here
    qmlRegisterType<AttachmentStore>(uri, 1, 0, "AttachmentStore");
}

void BackendPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);
}

