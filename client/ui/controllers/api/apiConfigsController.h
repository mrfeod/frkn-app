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

public slots:
    bool exportNativeConfig(const QString &serverCountryCode, const QString &fileName);

signals:
    void errorOccurred(ErrorCode errorCode);

private:
    struct ApiPayloadData
    {
        OpenVpnConfigurator::ConnectionData certRequest;

        QString wireGuardClientPrivKey;
        QString wireGuardClientPubKey;
    };

    ApiPayloadData generateApiPayloadData(const QString &protocol);
    QJsonObject fillApiPayload(const QString &protocol, const ApiPayloadData &apiPayloadData);

    QSharedPointer<ServersModel> m_serversModel;
    std::shared_ptr<Settings> m_settings;
};

#endif // APICONFIGSCONTROLLER_H
