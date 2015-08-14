#ifndef ATTACHMENTSTORE_H
#define ATTACHMENTSTORE_H

#include <QObject>
#include <QStandardPaths>
#include <QFileInfo>

class AttachmentStore : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString contentStoreInputUri READ contentStoreInputUri WRITE setContentStoreInputUri
               NOTIFY contentStoreInputUriChanged)
    Q_PROPERTY(QString uri READ uri)
    Q_PROPERTY(QString billId WRITE setBillId)
    Q_PROPERTY(QString billUri READ billUri)

public:
    explicit AttachmentStore(QObject *parent = 0);
    ~AttachmentStore();

    Q_INVOKABLE QString nextBillAttachRef(QString filenameUri);
    Q_INVOKABLE bool cleanup(QList<QString> attachmentsUri);
    Q_INVOKABLE bool remove(QFileInfo fileInfo);

Q_SIGNALS:
    void contentStoreInputUriChanged();
    void error(QString msg);

protected:
    QString contentStoreInputUri() { return m_contentStoreInputUri; }
    void setContentStoreInputUri(QString uri);
    QString m_contentStoreInputUri;

    void setBillId(QString billId) { m_billId = billId; }
    QString m_billId;

    QString uri() { return QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/attachments"; }
    QString billUri() { return uri() + "/" + m_billId; }
};

#endif // ATTACHMENTSTORE_H

