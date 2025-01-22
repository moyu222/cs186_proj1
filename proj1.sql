-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
   select max(era)
   from pitching-- replace this line
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  from people 
  where weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people p
  WHERE namefirst LIKE '% %'
  ORDER BY namefirst, namelast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), count(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, playerid, yearid
  FROM people p INNER JOIN HallofFame h ON p.playerid = h.playerid
  WHERE h.inducted = 'Y'
  ORDER BY h.yearid DESC, p.playid
;

-- Question 2ii
CREATE VIEW CAcollege(playerid, schoolid)
AS
	SELECT c.playerid, c.schoolid
    FROM collegeplaying c INNER JOIN schools s
    ON c.schoolid = s.schoolid
    WHERE s.schoolState = 'CA'
    ;
    
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, q.playerid, schoolid, yearid
  FROM q2i q INNER JOIN CAcollege c
  ON q.playerid = c.playerid
  ORDER BY yearid DESC, schoolid, q.playerid
  ;
  
  
-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q.playerid, namefirst, namelast, schoolid
  FROM q2i q LEFT OUTER JOIN collegeplaying c
  ON q.playerid = c.playerid
  ORDER BY q.playerid DESC, schoolid
  ;

-- Question 3i
CREATE VIEW slg(playerid, yearid, AB, slgval)
AS
	SELECT playerid, yearid, AB, (H + H2B + 2*H3B + 3*HR + 0.0)/(AB + 0.0)
    FROM batting;
    
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, s.yearid, s.slgval
  FROM people p INNER JOIN slg s
  ON p.playerid = s.playerid
  WHERE s.AB > 50
  ORDER BY s.slgval DESC, s.yearid, p.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW lslg(playerid, lslgval)
AS
  SELECT playerid, (SUM(H) + SUM(H2B) + 2 * SUM(H3B) + 3 * SUM(HR) + 0.0)/(SUM(AB) + 0.0)
  FROM batting
  GROUP BY playerid
  HAVING SUM(AB) > 50
  ;

CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, l.lslgval
  FROM people p INNER JOIN lslg l
  ON p.playerid = l.playerid
  ORDER BY l.lslgval DESC, p.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT p.namefirst, p.namelast, l.lslgval
  FROM people p INNER JOIN lslg l
  ON p.playerid = l.playerid
  WHERE l.lslgval >
	(
		SELECT lslgval
        FROM lslg
        WHERE playerid = 'mayswi01'
    )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  with salaries2016 as(
	select * from salaries
    where yearid = 2016
  ),
  salaryStats as (
    select MIN(salary) as mins, MAX(salary) as maxs, (MAX(salary) - MIN(salary))/10.0 as width
    from salaries2016
  ),
  salaryBin as (
    selcet s.salary, MIN(CAST((s.salary - salaryStats.mins)/width AS INT),9)
    from salaries2016 s, salaryStats
  )
  SELECT id.binid, id.binid*(select width from salaryStats)+(select mins from salaryStats), (id.binid+1)*(select width from salaryStats)+(select mins from salaryStats), count(*)
  from binids id LEFT JOIN salaryBins sb ON id.binid = sb.binid
  group by id.binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  with yearlyData AS(
    select yearid, min(salary) as mins, max(salary) as maxs , avg(salary) as avgs
    from salaries
    group by yearid
  )
  select d2.yearid, d2.mins-d1.mins, d2.maxs-d1.maxs, d2.avgs-d1.avgs
    from yearlyData d1
    INNER JOIN yearlyData d2 on d1.yearid+1 = d2.yearid
    order by d1.yearid asc
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  with maxSalaries as (
    select yearid, max(salary) as salary
    from salaries
    where yearid = 2001 or yearid = 2000
    group by yearid
  )
  select p.playerid, p.namefirst, p.namelast, ms.salary, ms.yearid
  from maxSalaries ms
  JOIN salaries s
  on ms.yearid = s.yearid and ms.salary = s.salary
  JOIN people p
  on s.playerid = p.playerid

  order by ms.yearid asc
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  with all2016 as (
    select * from allstarfull
    where yearid = 2016
  )
  select s.teamid, max(s.salary) - min(s.salary)
  from all2016
  JOIN salaries s
  ON all2016.playerid = s.playerid and all2016.teamid = s.teamid and s.yearid = 2016
  group by s.teamid
;

