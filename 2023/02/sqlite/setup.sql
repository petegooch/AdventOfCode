CREATE TABLE input ( [String] varchar(512) );
;
CREATE VIEW MoveListByGameId AS
  -- Extract our gameid and the semicolon-delimited list of moves from input
  SELECT
    cast(replace(substring(string,0,instr(string,':')),'Game ','') as integer) as 'gameid',
    substring(string,instr(string,':')+1,length(string)) as 'movelist'
  FROM input
;

CREATE VIEW MovesByGameId AS
  -- Break each move out to multiple records
  WITH RECURSIVE cte(gameid, moveid, move, remainingmoves) AS (
    SELECT
      gameid,
      0,
      '',
      movelist||';'
    FROM MoveListByGameId
    UNION ALL
    SELECT
      gameid,
      moveid+1,
      substring(remainingmoves,0,instr(remainingmoves,';')),
      substring(remainingmoves,instr(remainingmoves,';')+1,length(remainingmoves))
    FROM
      cte
    WHERE
      remainingmoves != ''
  )
  SELECT gameid, moveid, move FROM cte WHERE move != '' ORDER BY gameid, moveid
;

CREATE VIEW ColorCountsByMove AS
  WITH RECURSIVE cte(gameid, moveid, drawid, draw, remainingdraws) AS (
    SELECT
      gameid,
      moveid,
      0,
      '',
      move||','
    FROM
      MovesByGameId
    UNION ALL
    SELECT
      gameid,
      moveid,
      drawid+1,
      trim(substring(remainingdraws,0,instr(remainingdraws,','))) as draw,
      substring(remainingdraws,instr(remainingdraws,',')+1,length(remainingdraws)) as remainingdraws
    FROM
      cte
    WHERE
      remainingdraws != ''
  )
  SELECT
    gameid,
    moveid,
    drawid,
    substring(draw,instr(draw,' ')+1,length(draw)) as color,
    cast(substring(draw,0,instr(draw,' ')) as integer) as pullcount
  FROM
    cte
  WHERE
    draw != ''
  ORDER BY gameid, moveid, drawid
;

CREATE VIEW CountsByMove AS
  SELECT
    gameid,
    moveid,
    ifnull((
      select SUM(pullcount)
      FROM ColorCountsByMove c
      WHERE g.gameid = c.gameid AND g.moveid = c.moveid AND color = 'red'
      GROUP BY color
    ),0) AS redcount,
    ifnull((
      select SUM(pullcount)
      FROM ColorCountsByMove c
      WHERE g.gameid = c.gameid AND g.moveid = c.moveid AND color = 'green'
      GROUP BY color
    ),0) AS greencount,
    ifnull((
      select SUM(pullcount)
      FROM ColorCountsByMove c
      WHERE g.gameid = c.gameid AND g.moveid = c.moveid AND color = 'blue'
      GROUP BY color
    ),0) AS bluecount
  FROM
    MovesByGameId g
;

