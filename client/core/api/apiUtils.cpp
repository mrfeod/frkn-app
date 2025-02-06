#include "apiUtils.h"

#include <QDateTime>

bool ApiUtils::isSubscriptionExpired(const QString &subscriptionEndDate)
{
    QDateTime now = QDateTime::currentDateTime();
    QDateTime endDate = QDateTime::fromString(subscriptionEndDate, Qt::ISODateWithMs);
    return endDate < now;
}
