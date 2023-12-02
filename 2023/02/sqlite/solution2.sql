-- Second solution
SELECT
  SUM(cubepower) AS answer_2
FROM
(
  SELECT
    gameid, requiredred * requiredgreen * requiredblue as cubepower
  FROM
  (
    SELECT
      gameid,
      MAX(redcount) as requiredred,
      MAX(greencount) as requiredgreen,
      MAX(bluecount) as requiredblue
    FROM
      CountsByMove
    GROUP BY gameid
  ) requiredcounts
) withcubepower
;
