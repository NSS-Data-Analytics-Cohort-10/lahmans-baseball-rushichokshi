-- ## Lahman Baseball Database Exercise
-- - this data has been made available [online](http://www.seanlahman.com/baseball-archive/statistics/) by Sean Lahman
-- - A data dictionary is included with the files for this project.

-- ### Use SQL queries to find answers to the *Initial Questions*. If time permits, choose one (or more) of the *Open-Ended Questions*. Toward the end of the bootcamp, we will revisit this data if time allows to combine SQL, Excel Power Pivot, and/or Python to answer more of the *Open-Ended Questions*.



-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 

SELECT MIN(yearid),MAX(yearid)
FROM appearances;

SELECT MIN(year),MAX(year)
FROM homegames;

SELECT MIN(yearid),MAX(yearid)
FROM collegeplaying;

SELECT MIN(yearid),MAX(yearid)
FROM teams;

--ANSWER: 1871-2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?


SELECT *
FROM people
WHERE height IN
	(SELECT MIN(height)
	FROM people);

SELECT *
FROM people
JOIN appearances
USING (playerid)
WHERE height IN
	(SELECT MIN(height)
	FROM people);


SELECT namefirst, namelast, namegiven, height, name, g_all
FROM people
INNER JOIN appearances
USING (playerid)
INNER JOIN teams
USING (teamid)
WHERE height IN
	(SELECT MIN(height)
	FROM people);
	


--ANSWER: Eddie Gaedel (given name Edward Carl), 43 inches tall, 1 game




-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?



SELECT namefirst, namelast, SUM(salary) as total_salary
FROM people
LEFT JOIN collegeplaying
USING (playerid)
LEFT JOIN salaries
USING (playerid)
WHERE schoolid = 'vandy' AND lgid = 'NL'
GROUP BY playerid
ORDER BY total_salary DESC;



SELECT namefirst, namelast, SUM(salary) as total_salary
FROM people
LEFT JOIN collegeplaying
USING (playerid)
LEFT JOIN salaries
USING (playerid)
WHERE schoolid = 'vandy'
GROUP BY playerid
HAVING SUM(salary) IS NOT NULL
ORDER BY total_salary DESC;



--ANSWER: David Price

	

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

	

SELECT
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'SS' THEN 'Infield'
	WHEN pos = '1B' THEN 'Infield'
	WHEN pos = '2B' THEN 'Infield'
	WHEN pos = '3B' THEN 'Infield'
	WHEN pos = 'P' THEN 'Battery'
	WHEN pos = 'C' THEN 'Battery'
	ELSE NULL END AS position,
	SUM(po)
FROM fielding
WHERE yearid = 2016
GROUP BY position;


--ANSWER: Battery: 41,424; Infield: 58,934; Outfield: 29,560


   
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT FLOOR((yearid/10)*10) as decade, ROUND(AVG(so/g),2) as avg_so, ROUND(AVG(hr/g),2) as avg_hr
FROM teams
WHERE yearid>=1920
GROUP BY decade
ORDER BY decade

   

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.


SELECT playerid, namefirst, namelast, TO_CHAR((sb*100)/sum(sb+cs),'fm99%') AS sbs
FROM batting
LEFT JOIN people
USING (playerid)
WHERE (sb+cs)>= 20 AND yearid= 2016
GROUP BY batting.playerid, people.namefirst, people.namelast, batting.sb
ORDER BY sbs DESC;

--ANSWER: Chris Owings, 91%
	

-- 7.  PART 1) From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
--	PART 2) What is the smallest number of wins for a team that did win the world series?
--	PART 3) Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. 
--	PART 4) How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?




SELECT yearid, name, MAX(w)
FROM (SELECT *
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
		AND wswin = 'N') AS data
GROUP BY yearid, name
ORDER BY MAX(w) DESC

--ANSWER PART 1: Seattle Mariners in 2001 with 116 wins


SELECT yearid, name, MIN(w)
FROM (SELECT *
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
		AND wswin = 'Y') AS data
GROUP BY yearid, name
ORDER BY MIN(w) 

--ANSWER PART 2: Los Angeles Dodgers in 1981 with 63 wins


SELECT yearid, name, MIN(w)
FROM (SELECT *
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016 AND yearid<>1981
		AND wswin = 'Y') AS data
GROUP BY yearid, name
ORDER BY MIN(w) 

--ANSWER PART 3: St. Louis Cardinals in 2006 with 83 wins


--PART 4) How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?


SELECT *
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND yearid<>1981



SELECT yearid, name, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND yearid<>1981
ORDER BY yearid ASC, w DESC


SELECT yearid, MAX(w)
FROM (SELECT yearid, name, w, wswin
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	AND yearid<>1981
	ORDER BY yearid ASC, w DESC) AS subquery
GROUP BY yearid
ORDER BY yearid




SELECT yearid, MAX(w), (SELECT name
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	AND yearid<>1981
	ORDER BY yearid ASC, w DESC) AS name
FROM (SELECT yearid, name, w, wswin
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	AND yearid<>1981
	ORDER BY yearid ASC, w DESC) AS subquery
GROUP BY yearid
ORDER BY yearid








-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.




	

SELECT DISTINCT homegames.team, teams.name, parks.park_name, (homegames.attendance/homegames.games) AS avg_attendance
FROM homegames
LEFT JOIN teams
ON homegames.team = teams.teamid
LEFT JOIN parks
ON homegames.park=parks.park
WHERE homegames.games>=10
	AND homegames.year=2016
ORDER BY avg_attendance DESC

--ANSWER: top 5: Dodgers, Browns, Cardinals, Perfectors, Blue Jays; bottom 5: Rays, Oakland Athletics, Naps, Indians, Bronchos



-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

SELECT *
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
	AND lgid = 'AL' OR lgid = 'NL'
	
SELECT playerid, awardid, lgid
FROM awardsmanagers

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--     <ol type="a">
--       <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--       <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--     </ol>


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  
