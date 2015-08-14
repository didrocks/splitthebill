#include "attachmentstore.h"
#include <QDir>
#include <QDebug>

AttachmentStore::AttachmentStore(QObject *parent) :
    QObject(parent),
    m_contentStoreInputUri("")
{
    /*QDir foo = QDir("/home");
    qDebug() << "Path: " << foo.path();*/
}

AttachmentStore::~AttachmentStore() {

}


void AttachmentStore::setContentStoreInputUri(QString uri) {
    if (uri != m_contentStoreInputUri) {
        m_contentStoreInputUri = uri;
        qDebug() << "m_contentStoreInputUri changed " << m_contentStoreInputUri;

        /*
         * Cleaning up this contentstore exchange path as we use it as a temporary storage until
         * bug #<TODO> is fixed.
         * That way, even if the application crash during a transfer, we won't be stuck
         */
        if (!m_contentStoreInputUri.isEmpty()) {
            QDir exchange = QDir(m_contentStoreInputUri);
            if (!exchange.removeRecursively()) {
                // TODO: add i18n
                Q_EMIT error("Couldn't remove transient directory, please retry attachement");
            }

        }

        Q_EMIT contentStoreInputUriChanged();
    }
}
