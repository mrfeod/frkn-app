#ifndef APICONFIGSCONTROLLER_H
#define APICONFIGSCONTROLLER_H

#include <QObject>

#include "configurators/openvpn_configurator.h"
#include "ui/models/servers_model.h"

class ApiConfigsController : public QObject
{
    Q_OBJECT
public:
    ApiConfigsController(const QSharedPointer<ServersModel> &serversModel, const std::shared_ptr<Settings> &settings,
                         QObject *parent = nullptr);

    Q_PROPERTY(QList<QString> qrCodes READ getQrCodes NOTIFY vpnKeyExportReady)
    Q_PROPERTY(int qrCodesCount READ getQrCodesCount NOTIFY vpnKeyExportReady)

public slots:
    bool exportNativeConfig(const QString &serverCountryCode, const QString &fileName);
    // bool exportVpnKey(const QString &fileName);
    void prepareVpnKeyExport();

signals:
    void errorOccurred(ErrorCode errorCode);
    void vpnKeyExportReady();

private:
    struct ApiPayloadData
    {
        OpenVpnConfigurator::ConnectionData certRequest;

        QString wireGuardClientPrivKey;
        QString wireGuardClientPubKey;
    };

    ApiPayloadData generateApiPayloadData(const QString &protocol);
    QJsonObject fillApiPayload(const QString &protocol, const ApiPayloadData &apiPayloadData);

    QList<QString> getQrCodes();
    int getQrCodesCount();

    QList<QString> m_qrCodes;

    QSharedPointer<ServersModel> m_serversModel;
    std::shared_ptr<Settings> m_settings;
};

#endif // APICONFIGSCONTROLLER_H
