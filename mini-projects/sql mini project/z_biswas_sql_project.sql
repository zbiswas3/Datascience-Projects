/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name FROM Facilities WHERE Facilities.membercost>0

/*

name
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court

*/


/* Q2: How many facilities do not charge a fee to members? */

SELECT count(name) FROM Facilities WHERE Facilities.membercost=0
/* 4 facilities do not charge a fee to members*/


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance FROM Facilities where membercost < 0.2 * monthlymaintenance

/*
facid name  membercost monthlymaintenance
0	Tennis Court 1	5.0	200
1	Tennis Court 2	5.0	200
2	Badminton Court	0.0	50
3	Table Tennis	0.0	10
4	Massage Room 1	9.9	3000
5	Massage Room 2	9.9	3000
6	Squash Court	3.5	80
7	Snooker Table	0.0	15
8	Pool Table	0.0	15


*/

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

/*option 1: using UNION */
SELECT * FROM Facilities where facid = 1
UNION
SELECT * FROM Facilities where facid = 5

/* optional 2 using IN: 

SELECT * FROM Facilities where facid IN (1,5)

*/

/*
facid name 		membercost guestcost initialoutlay monthlymaintenance
1	Tennis Court 2	5.0	25.0	8000	200
5	Massage Room 2	9.9	80.0	4000	3000
*/


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

/* option: Label as a seperate column */
SELECT name, 'cheap' as Label, monthlymaintenance FROM Facilities where monthlymaintenance < 100
UNION
SELECT name, 'expensive' as Label, monthlymaintenance FROM Facilities where monthlymaintenance >100
ORDER BY name

/*
name  			Lable   monthlymaintenance
Badminton Court	cheap	50
Massage Room 1	expensive	3000
Massage Room 2	expensive	3000
Pool Table	cheap	15
Snooker Table	cheap	15
Squash Court	cheap	80
Table Tennis	cheap	10
Tennis Court 1	expensive	200
Tennis Court 2	expensive	200

*/
/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname,surname FROM Members
where memid >(select max(memid)-4 From Members)
ORDER BY joindate DESC 

/*
firstname surname
Darren	Smith
Erica	Crumpet
John	Hunt


*/

/* Can be done using top 3 query

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT f.name as 'Court Name',If(m.memid =0,m.firstname, concat(m.firstname,' ',m.surname)) AS 'Member Name'  FROM Members AS m, Facilities as f
where f.name Like 'Tennis%' Order by m.firstname
/* It can be done using JOIN ON memberid

/*
Court Name 		Member Name
Tennis Court 1	Anna Mackenzie
Tennis Court 2	Anna Mackenzie
Tennis Court 2	Anne Baker
Tennis Court 1	Anne Baker
Tennis Court 1	Burton Tracy
Tennis Court 2	Burton Tracy
Tennis Court 1	Charles Owen
Tennis Court 2	Charles Owen
Tennis Court 2	Darren Smith
Tennis Court 1	Darren Smith
Tennis Court 2	David Farrell
Tennis Court 1	David Jones
Tennis Court 2	David Pinker
Tennis Court 1	David Farrell
Tennis Court 1	David Pinker
Tennis Court 2	David Jones
Tennis Court 1	Douglas Jones
Tennis Court 2	Douglas Jones
Tennis Court 2	Erica Crumpet
Tennis Court 1	Erica Crumpet
Tennis Court 1	Florence Bader
Tennis Court 2	Florence Bader
Tennis Court 2	Gerald Butters
.....
*/




/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT DISTINCT f.name, concat(m.firstname,' ',surname) as 'Member Name', SUM(b.slots*f.membercost) as 'Cost' FROM `Bookings`b , Members m, Facilities f 
where b.starttime Like '2012-09-14%' AND b.memid = m.memid AND f.facid = b.facid AND NOT m.memid = 0 
GROUP BY m.memid 
Having Cost > 30
UNION
SELECT DISTINCT f.name, m.firstname as 'Member Name', b.slots*f.guestcost AS 'Cost' FROM `Bookings`b , Members m, Facilities f 
where b.starttime Like '2012-09-14%' AND b.memid = m.memid AND f.facid = b.facid AND m.memid = 0
Having Cost > 30
ORDER BY Cost  DESC 

/*

Massage Room 2	GUEST	320.0
Massage Room 1	GUEST	160.0
Tennis Court 2	GUEST	150.0
Tennis Court 2	GUEST	75.0
Tennis Court 1	GUEST	75.0
Squash Court	GUEST	70.0
Massage Room 1	Jemima Farrell	59.4
Squash Court	GUEST	35.0
Tennis Court 1	Burton Tracy	34.8


*/


/* Q9: This time, produce the same result as in Q8, but using a subquery. */


SELECT	guests.name as 'Facility Name',
		surname AS 'Member Name',
		guests.cost as cost
		FROM Members m
		INNER JOIN (SELECT b.memid, f.name, slots*guestcost as cost
              FROM Bookings b
              INNER JOIN Facilities f
				ON b.facid = f.facid
 				WHERE starttime Like '2012-09-14%'
			 	AND memid = 0) guests            
			ON m.memid = guests.memid
		Having cost > 30

UNION

SELECT  members.name as 'Facility Name',
		concat(m.firstname, ' ', m.surname) AS 'Member Name',
		members.cost as cost
		FROM Members m
		INNER JOIN(SELECT b.memid, f.name, SUM(f.membercost*b.slots) AS cost
        FROM Bookings b
		INNER JOIN Facilities f
			ON b.facid = f.facid
		INNER JOIN Members m
			ON m.memid = b.memid
		WHERE starttime Like '2012-09-14%'
		AND m.memid <> 0
		GROUP BY m.memid) members
		ON m.memid = members.memid
		Having cost > 30
		ORDER BY cost DESC
		
/*
Massage Room 2	GUEST	320.0
Massage Room 1	GUEST	160.0
Tennis Court 2	GUEST	150.0
Tennis Court 2	GUEST	75.0
Tennis Court 1	GUEST	75.0
Squash Court	GUEST	70.0
Massage Room 1	Jemima Farrell	59.4
Squash Court	GUEST	35.0
Tennis Court 1	Burton Tracy	34.8

*/		
		

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

Select Name, sum(Revenue) as 'Total Revenue' From (Select f.name as Name, f.membercost*b.slot as Revenue From (SELECT facid, sum(slots) as slot FROM Bookings
Where memid <> 0
Group by facid) b 
Join Facilities f
On b.facid = f.facid
Union
Select f.name as Name, f.guestcost*b.slot as  Revenue From (SELECT facid, sum(slots) as slot FROM Bookings
Where memid = 0
Group by facid) b 
Join Facilities f
On b.facid = f.facid) T
Group by T.Name
Having sum(Revenue) < 1000
Order by T.Revenue

/*
Name 		Total Revenue
Pool Table	270.0
Snooker Table	240.0
Table Tennis	180.0

*/
