#include "attachmentstore.h"
#include <QDir>
#include <QDebug>

AttachmentStore::AttachmentStore(QObject *parent) :
    QObject(parent),
    m_contentStoreInputUri("") {
}

AttachmentStore::~AttachmentStore() {

}

void AttachmentStore::setContentStoreInputUri(QString uri) {
    if (uri != m_contentStoreInputUri) {
        m_contentStoreInputUri = uri;

        /*
         * Cleaning up this contentstore exchange path as we use it as a temporary storage until
         * bug #<TODO> is fixed.
         * That way, even if the application crash during a transfer, we won't be stuck
         */
        if (!m_contentStoreInputUri.isEmpty()) {
            QDir exchange = QDir(m_contentStoreInputUri);
            if (!exchange.removeRecursively()) {
                // TODO: add i18n
                // COMMENT: show raising an signal with parameters to QML
                Q_EMIT error("Couldn't remove transient directory, please retry attachement");
            }

        }
        Q_EMIT contentStoreInputUriChanged();
    }
}

QString AttachmentStore::nextBillAttachRef(QString filenameUri) {
    QString attachPattern("attachment_%1.%2");
    QFileInfo origFile(filenameUri);
    QString currentBillAttachRef;
    int i = 0;

    // look at first valid attachment file to save
    do {
        i++;
        currentBillAttachRef = attachPattern.arg(i).arg(origFile.suffix());
    } while(QFile(billUri() + "/" + currentBillAttachRef).exists());

    return currentBillAttachRef;
}
