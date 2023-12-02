-- First solution
WITH BadGameIds AS (
  SELECT DISTINCT gameid FROM CountsByMove WHERE redcount > 12 OR greencount > 13 OR bluecount > 14
)
SELECT SUM(gameid) AS answer_1 FROM MoveListByGameId g WHERE NOT EXISTS ( SELECT gameid FROM BadGameIds b WHERE b.gameid = g.gameid )
;
