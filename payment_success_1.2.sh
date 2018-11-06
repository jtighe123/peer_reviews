#!/bin/bash
DATE=`date '+%Y-%m-%d %H:%M:%S'`
EMAIL_1="no-payments@missguided.pagerduty.com"
EMAIL_2="servicedesk@missguided.com"

RESULT_P24=`mysql -h prod-aurora-db-read-2.mgprod.co.uk missguided_live -e "select COUNT(*)
FROM sales_flat_order o INNER JOIN sales_flat_order_payment p ON p.parent_id = o.entity_id
WHERE o.created_at > (select date_sub(now(), interval 6 hour)) AND o.created_at < (select now())
AND o.store_id = 10 AND p.method = 'p24'" | grep -v COUNT`

RESULT_KLARNA=`mysql -h prod-aurora-db-read-2.mgprod.co.uk missguided_live -e "select COUNT(*)
FROM sales_flat_order o INNER JOIN sales_flat_order_payment p ON p.parent_id = o.entity_id
WHERE o.created_at > (select date_sub(now(), interval 6 hour)) AND o.created_at < (select now())
AND o.store_id = 5 AND p.method = 'vaimo_klarna_checkout'" | grep -v COUNT`

if [ "$RESULT_P24" -eq 0 ];
 then
 echo "There has been no P24 payments for 6 hours, as of $DATE" | mail -s "NO P24 PAYMENTS" -r "Josh.t@missguided.com" $EMAIL_1 $EMAIL_2
fi

 if [ "$RESULT_KLARNA" -eq 0 ];
then
 echo "There has been no Klarna payments for 6 hours, as of $DATE" | mail -s "NO KLARNA PAYMENTS" -r "Josh.t@missguided.com" $EMAIL_1 $EMAIL_2
fi

exit 0
