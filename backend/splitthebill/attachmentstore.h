#ifndef ATTACHMENTSTORE_H
#define ATTACHMENTSTORE_H

#include <QObject>

class AttachmentStore : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString contentStoreInputUri READ contentStoreInputUri WRITE setContentStoreInputUri
               NOTIFY contentStoreInputUriChanged)

public:
    explicit AttachmentStore(QObject *parent = 0);
    ~AttachmentStore();

Q_SIGNALS:
    void contentStoreInputUriChanged();
    void error(QString msg);

protected:
    QString contentStoreInputUri() { return m_contentStoreInputUri; }
    void setContentStoreInputUri(QString uri);

    QString m_contentStoreInputUri;
};

#endif // ATTACHMENTSTORE_H

