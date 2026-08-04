-- Preview rows that will be inserted (RecordStatus = 'New - Insert' from APAC file)
SELECT
    src.CustomerName,
    src.CustomerNumber,
    ISNULL(MIN(dc.Location), '') AS [Location],
    src.Region,
    'Yes' AS Active,
    src.Bucket AS CustomerBucket
FROM (
    VALUES
        ('HOYO ELECTRONICS CO., LIMITED', 'R78940', 'APAC', 'Electronics'),
        ('SHENZHENSHI XINGHUO MAOYI YOUXIAN GONGSI', 'R78875', 'CHINA', 'Electronics'),
        ('SUZHOU YIANGTUO ELECTRONICS CO., LTD.', 'R78880', 'CHINA', 'Electronics'),
        ('BEIJING FUCHANG XINCHENG ELECTRONICS', 'R78900', 'CHINA', 'Electronics'),
        ('YINLI (SHENZHEN) TECHNOLOGY CO., LTD.', 'R78950', 'CHINA', 'Electronics')
) AS src (CustomerName, CustomerNumber, Region, Bucket)
INNER JOIN Dimension.Dim_Customer dc
    ON dc.CustomerNumber = src.CustomerNumber
INNER JOIN Dimension.Dim_Region dr
    ON dr.Location = dc.Location
   AND dr.Region = src.Region
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.CustomerBucket cb
    WHERE cb.Region = src.Region
      AND cb.CustomerNumber = src.CustomerNumber
)
GROUP BY
    src.CustomerName,
    src.CustomerNumber,
    src.Region,
    src.Bucket;


INSERT INTO dbo.CustomerBucket
(
    CustomerName,
    CustomerNumber,
    [Location],
    Region,
    Active,
    CustomerBucket
)
SELECT
    src.CustomerName,
    src.CustomerNumber,
    ISNULL(MIN(dc.Location), '') AS [Location],
    src.Region,
    'Yes' AS Active,
    src.Bucket AS CustomerBucket
FROM (
    VALUES
        ('HOYO ELECTRONICS CO., LIMITED', 'R78940', 'APAC', 'Electronics'),
        ('SHENZHENSHI XINGHUO MAOYI YOUXIAN GONGSI', 'R78875', 'CHINA', 'Electronics'),
        ('SUZHOU YIANGTUO ELECTRONICS CO., LTD.', 'R78880', 'CHINA', 'Electronics'),
        ('BEIJING FUCHANG XINCHENG ELECTRONICS', 'R78900', 'CHINA', 'Electronics'),
        ('YINLI (SHENZHEN) TECHNOLOGY CO., LTD.', 'R78950', 'CHINA', 'Electronics')
) AS src (CustomerName, CustomerNumber, Region, Bucket)
INNER JOIN Dimension.Dim_Customer dc
    ON dc.CustomerNumber = src.CustomerNumber
INNER JOIN Dimension.Dim_Region dr
    ON dr.Location = dc.Location
   AND dr.Region = src.Region
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.CustomerBucket cb
    WHERE cb.Region = src.Region
      AND cb.CustomerNumber = src.CustomerNumber
)
GROUP BY
    src.CustomerName,
    src.CustomerNumber,
    src.Region,
    src.Bucket;
