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

    if (m_billId.isEmpty()) {
        qWarning() << "Can not be called without having a billId associated";
        return "";
    }

    // look at first valid attachment file to save
    do {
        i++;
        currentBillAttachRef = attachPattern.arg(i).arg(origFile.suffix());
    } while(QFile(billUri() + "/" + currentBillAttachRef).exists());

    return currentBillAttachRef;
}

bool AttachmentStore::cleanup(QList<QString> attachmentsUri) {
    bool success = true;

    if (m_billId.isEmpty()) {
        qWarning() << "Can not be called without having a billId associated";
        return false;
    }

    QDir curdir = QDir(billUri());
    QFileInfoList list = curdir.entryInfoList();

    for (int i = 0; i < list.size(); i++) {
        QFileInfo fileInfo = list.at(i);

        // we don't want to delete . or ..
        if (curdir.absolutePath().contains(fileInfo.absoluteFilePath()))
            continue;

        if (!attachmentsUri.contains(fileInfo.absoluteFilePath())) {
            if (!remove(fileInfo))
                success = false;
        }
    }
    return success;
}

bool AttachmentStore::remove(QFileInfo fileInfo) {
    if (fileInfo.isFile())
        return QFile(fileInfo.absoluteFilePath()).remove();
    return QDir(fileInfo.absoluteFilePath()).removeRecursively();
}
