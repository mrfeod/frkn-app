#ifndef APIACCOUNTINFOMODEL_H
#define APIACCOUNTINFOMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QJsonObject>

#include "core/api/apiDefs.h"

class ApiAccountInfoModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        SubscriptionStatusRole = Qt::UserRole + 1,
        ConnectedDevicesRole,
        ServiceDescriptionRole,
        EndDateRole,
        IsComponentVisibleRole
    };

    explicit ApiAccountInfoModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

public slots:
    void updateModel(const QJsonObject &accountInfoObject, const QJsonObject &serverConfig);
    QVariant data(const QString &roleString);

    QJsonArray getAvailableCountries();
    QJsonArray getIssuedConfigsInfo();
    QString getTelegramBotLink();

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    struct AccountInfoData
    {
        QString subscriptionEndDate;
        int activeDeviceCount;
        int maxDeviceCount;

        apiDefs::ConfigType configType;
    };

    AccountInfoData m_accountInfoData;
    QJsonArray m_availableCountries;
    QJsonArray m_issuedConfigsInfo;
};

#endif // APIACCOUNTINFOMODEL_H
