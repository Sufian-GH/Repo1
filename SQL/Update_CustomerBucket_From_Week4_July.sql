-- Preview rows that will be updated
SELECT
    t.Region,
    t.CustomerNumber,
    t.CustomerBucket AS CurrentCustomerBucket,
    src.Bucket AS NewCustomerBucket
FROM dbo.CustomerBucket t
INNER JOIN (
    VALUES
        ('AMERICAS', 'R07150', 'Electrical'),
        ('AMERICAS', 'R25105', 'Electronics'),
        ('AMERICAS', 'R28800', 'Electrical'),
        ('AMERICAS', 'R35865', 'Electrical'),
        ('AMERICAS', 'R42205', 'Electrical'),
        ('AMERICAS', 'R43720', 'Electrical'),
        ('AMERICAS', 'R44235', 'Electronics'),
        ('AMERICAS', 'R58830', 'Electrical'),
        ('AMERICAS', 'R59120', 'Electrical'),
        ('AMERICAS', 'R60370', 'Electrical'),
        ('AMERICAS', 'R62700', 'Electrical'),
        ('AMERICAS', 'R68025', 'Electrical'),
        ('AMERICAS', 'R70140', 'Electronics'),
        ('AMERICAS', 'R70190', 'Electrical'),
        ('AMERICAS', 'R72180', 'Electronics'),
        ('AMERICAS', 'R77630', 'Electrical'),
        ('APAC', 'R63710', 'Electronics'),
        ('APAC', 'R77660', 'Electronics'),
        ('APAC', 'R77965', 'Electronics'),
        ('APAC', 'R78855', 'Electronics'),
        ('CHINA', 'R78405', 'Electronics')
) AS src (Region, CustomerNumber, Bucket)
    ON t.Region = src.Region
   AND t.CustomerNumber = src.CustomerNumber
WHERE t.CustomerBucket = 'Unclassified';
UPDATE t
SET t.CustomerBucket = src.Bucket
FROM dbo.CustomerBucket t
INNER JOIN (
    VALUES
        ('AMERICAS', 'R07150', 'Electrical'),
        ('AMERICAS', 'R25105', 'Electronics'),
        ('AMERICAS', 'R28800', 'Electrical'),
        ('AMERICAS', 'R35865', 'Electrical'),
        ('AMERICAS', 'R42205', 'Electrical'),
        ('AMERICAS', 'R43720', 'Electrical'),
        ('AMERICAS', 'R44235', 'Electronics'),
        ('AMERICAS', 'R58830', 'Electrical'),
        ('AMERICAS', 'R59120', 'Electrical'),
        ('AMERICAS', 'R60370', 'Electrical'),
        ('AMERICAS', 'R62700', 'Electrical'),
        ('AMERICAS', 'R68025', 'Electrical'),
        ('AMERICAS', 'R70140', 'Electronics'),
        ('AMERICAS', 'R70190', 'Electrical'),
        ('AMERICAS', 'R72180', 'Electronics'),
        ('AMERICAS', 'R77630', 'Electrical'),
        ('APAC', 'R63710', 'Electronics'),
        ('APAC', 'R77660', 'Electronics'),
        ('APAC', 'R77965', 'Electronics'),
        ('APAC', 'R78855', 'Electronics'),
        ('CHINA', 'R78405', 'Electronics')
) AS src (Region, CustomerNumber, Bucket)
    ON t.Region = src.Region
   AND t.CustomerNumber = src.CustomerNumber
WHERE t.CustomerBucket = 'Unclassified';
