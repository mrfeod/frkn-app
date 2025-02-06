#ifndef APISETTINGSCONTROLLER_H
#define APISETTINGSCONTROLLER_H

#include <QObject>

#include "ui/models/api/apiAccountInfoModel.h"
#include "ui/models/servers_model.h"

class ApiSettingsController : public QObject
{
    Q_OBJECT
public:
    ApiSettingsController(const QSharedPointer<ServersModel> &serversModel, const QSharedPointer<ApiAccountInfoModel> &apiAccountInfoModel,
                          const std::shared_ptr<Settings> &settings, QObject *parent = nullptr);
    ~ApiSettingsController();

public slots:
    bool getAccountInfo();

private:
    QSharedPointer<ServersModel> m_serversModel;
    QSharedPointer<ApiAccountInfoModel> m_apiAccountInfoModel;

    std::shared_ptr<Settings> m_settings;
};

#endif // APISETTINGSCONTROLLER_H
