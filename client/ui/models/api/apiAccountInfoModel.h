#ifndef APIACCOUNTINFOMODEL_H
#define APIACCOUNTINFOMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QJsonObject>

class ApiAccountInfoModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        SubscriptionStatusRole = Qt::UserRole + 1,
        ConnectedDevicesRole,
        ServiceDescriptionRole,
        EndDateRole
    };

    explicit ApiAccountInfoModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

public slots:
    void updateModel(const QJsonObject &accountInfoObject, const QJsonObject &serverConfig);
    QVariant data(const QString &roleString);

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    struct CountryInfo
    {
        QString serverCountryCode;
        QString serverCountryName;
        QString lastUpdated;
    };

    struct AccountInfoData
    {
        QString subscriptionEndDate;
        int activeDeviceCount;
        int maxDeviceCount;

        QString vpnKey;

        QVector<CountryInfo> AvailableCountries;
    };

    AccountInfoData m_accountInfoData;
};

#endif // APIACCOUNTINFOMODEL_H
