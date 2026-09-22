-- Preview rows that will be updated
SELECT
    t.Region,
    t.CustomerNumber,
    t.CustomerBucket AS CurrentCustomerBucket,
    src.Bucket AS NewCustomerBucket
FROM dbo.CustomerBucket t
INNER JOIN (
    VALUES
        ('CHINA', 'R77005', 'Electronics')
) AS src (Region, CustomerNumber, Bucket)
    ON t.Region = src.Region
   AND t.CustomerNumber = src.CustomerNumber
WHERE t.CustomerBucket = 'Unclassified';

UPDATE t
SET t.CustomerBucket = src.Bucket
FROM dbo.CustomerBucket t
INNER JOIN (
    VALUES
     ('CHINA', 'R77005', 'Electronics')
) AS src (Region, CustomerNumber, Bucket)
    ON t.Region = src.Region
   AND t.CustomerNumber = src.CustomerNumber
WHERE t.CustomerBucket = 'Unclassified';

-- After update check
select  t.Region, t.CustomerNumber, t.CustomerBucket
from dbo.CustomerBucket t
where t.CustomerNumber='R77005' and t.Region='CHINA'
