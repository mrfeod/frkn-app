#include "apiAccountInfoModel.h"

#include <QJsonObject>

#include "core/api/apiUtils.h"
#include "logger.h"

namespace
{
    Logger logger("AccountInfoModel");

    namespace configKey
    {
        constexpr char availableCountries[] = "available_countries";
        // constexpr char serverCountryCode[] = "server_country_code";
        // constexpr char serverCountryName[] = "server_country_name";
        // constexpr char lastUpdated[] = "last_updated";
        constexpr char activeDeviceCount[] = "active_device_count";
        constexpr char maxDeviceCount[] = "max_device_count";
        constexpr char subscriptionEndDate[] = "subscription_end_date";
    }
}

ApiAccountInfoModel::ApiAccountInfoModel(QObject *parent) : QAbstractListModel(parent)
{
}

int ApiAccountInfoModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return 1;
}

QVariant ApiAccountInfoModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= static_cast<int>(rowCount()))
        return QVariant();

    switch (role) {
    case SubscriptionStatusRole: {
        return apiUtils::isSubscriptionExpired(m_accountInfoData.subscriptionEndDate) ? tr("Inactive") : tr("Active");
    }
    case EndDateRole: {
        return QDateTime::fromString(m_accountInfoData.subscriptionEndDate, Qt::ISODate).toLocalTime().toString("d MMM yyyy");
    }
    case ConnectedDevicesRole: {
        return tr("%1 out of %2").arg(m_accountInfoData.activeDeviceCount).arg(m_accountInfoData.maxDeviceCount);
    }
    case ServiceDescriptionRole: {
        if (m_accountInfoData.configType == apiDefs::ConfigType::AmneziaPremiumV2) {
            return tr("Classic VPN for comfortable work, downloading large files and watching videos. Works for any sites. Speed up to 200 "
                      "Mb/s");
        } else if (m_accountInfoData.configType == apiDefs::ConfigType::AmneziaFreeV3) {
            return tr("Free unlimited access to a basic set of websites such as Facebook, Instagram, Twitter (X), Discord, Telegram and "
                      "more. YouTube is not included in the free plan.");
        }
    }
    }

    return QVariant();
}

void ApiAccountInfoModel::updateModel(const QJsonObject &accountInfoObject, const QJsonObject &serverConfig)
{
    beginResetModel();

    AccountInfoData accountInfoData;

    m_availableCountries = accountInfoObject.value(configKey::availableCountries).toArray();
    // for (const auto &country : availableCountries) {
    //     auto countryObject = country.toObject();
    //     CountryInfo countryInfo;
    //     countryInfo.serverCountryCode = countryObject.value(configKey::serverCountryCode).toString();
    //     countryInfo.serverCountryName = countryObject.value(configKey::serverCountryName).toString();
    //     countryInfo.lastUpdated = countryObject.value(configKey::lastUpdated).toString();

    //     accountInfoData.AvailableCountries.push_back(countryInfo);
    // }

    accountInfoData.activeDeviceCount = accountInfoObject.value(configKey::activeDeviceCount).toInt();
    accountInfoData.maxDeviceCount = accountInfoObject.value(configKey::maxDeviceCount).toInt();
    accountInfoData.subscriptionEndDate = accountInfoObject.value(configKey::subscriptionEndDate).toString();

    accountInfoData.configType = apiUtils::getConfigType(serverConfig);

    m_accountInfoData = accountInfoData;

    endResetModel();
}

QVariant ApiAccountInfoModel::data(const QString &roleString)
{
    QModelIndex modelIndex = index(0);
    auto roles = roleNames();
    for (auto it = roles.begin(); it != roles.end(); it++) {
        if (QString(it.value()) == roleString) {
            return data(modelIndex, it.key());
        }
    }

    return {};
}

QJsonArray ApiAccountInfoModel::getAvailableCountries()
{
    return m_availableCountries;
}

QHash<int, QByteArray> ApiAccountInfoModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[SubscriptionStatusRole] = "subscriptionStatus";
    roles[EndDateRole] = "endDate";
    roles[ConnectedDevicesRole] = "connectedDevices";
    roles[ServiceDescriptionRole] = "serviceDescription";

    return roles;
}
