APOC START COMMANDS

	CALL apoc.mongodb.get("localhost","test","restaurants",{}) YIELD value as doc
	CREATE (r:Restaurant {name:doc.name, id:doc.restaurant_id})
	CREATE (r)-[:LOCATED_AT]->(a:Address) SET a = doc.address
	MERGE (b:Borough {name:doc.borough})
	CREATE (a)-[:IN_BOROUGH]->(b)
	MERGE (c:Cuisine {name: doc.cuisine})
	CREATE (r)-[:CUISINE]->(c)
	WITH r, (doc.grades) AS grades
	UNWIND grades AS gd
	MERGE (rv:Review {grade: gd.grade})
	ON CREATE SET rv.score = 0
	ON MATCH SET rv.score = gd.score
	CREATE (r)-[:HAS_REVIEW]->(rv)


QUERY 1

MATCH (r:Restaurant)-[:CUISINE]->(c:Cuisine)
WITH c, COUNT(c) as Count ORDER BY Count DESC LIMIT 1
MATCH (r:Restaurant)
RETURN c.name AS Cuisine, 100 * Count / count(r) AS Percentage

╒═══════════╤════════════╕
│"Cuisine"  │"Percentage"│
╞═══════════╪════════════╡
│"American "│"24"        │
└───────────┴────────────┘

QUERY 2

MATCH (r:Restaurant)-[:CUISINE]->(c:Cuisine)
WITH c, COUNT(c) AS pop ORDER BY pop DESC LIMIT 1
MATCH (b:Borough)<-[:IN_BOROUGH]-(:Address)<-[:LOCATED_AT]-(:Restaurant)-[:CUISINE]->(c1:Cuisine)
WHERE c1.name = "American "
WITH pop, b, COUNT(c1) AS numb
WHERE NOT b.name = "Missing"
RETURN b.name AS Borough, round(100 * numb / COUNT(b) * 100.0 / pop)/100 AS Percentage ORDER BY Percentage LIMIT 1

╒═══════════════╤════════════╕
│"Borough"      │"Percentage"│
╞═══════════════╪════════════╡
│"Staten Island"│3.95        │
└───────────────┴────────────┘

QUERY 3

MATCH(b:Borough)<-[:IN_BOROUGH]-(a:Address)<-[:LOCATED_AT]-(r:Restaurant)-[:CUISINE]->(c:Cuisine)
WHERE c.name = "American " AND b.name = "Staten Island"
WITH COUNT(c) AS numb
MATCH(b:Borough)<-[:IN_BOROUGH]-(a:Address)<-[:LOCATED_AT]-(:Restaurant)-[:CUISINE]->(c:Cuisine)
WHERE c.name = "American " AND b.name = "Staten Island"
RETURN a.zipcode AS zipcode, round(100 * 100.0 * count(c)/numb)/100 AS Percentage ORDER BY Percentage LIMIT 1

╒═════════╤════════════╕
│"zipcode"│"Percentage"│
╞═════════╪════════════╡
│"10311"  │0.41        │
└─────────┴────────────┘

QUERY 4

MATCH (b:Borough)<-[:IN_BOROUGH]-(a:Address)<-[:LOCATED_AT]-(r:Restaurant)-[:CUISINE]->(c:Cuisine)
WHERE c.name = "American " AND b.name = "Staten Island" AND a.zipcode = "10311"
WITH r
MATCH (r:Restaurant)-[:HAS_REVIEW]->(rv:Review)
WITH round(100*AVG(rv.score))/100 as Avg, COUNT(rv.score) as Total, r
WHERE Total >= 4
RETURN r.name AS Name, Total AS Total_Reviews, Avg AS Average_Score ORDER BY Avg DESC LIMIT 3

╒══════════════╤═══════════════╤═══════════════╕
│"Name"        │"Total_Reviews"│"Average_Score"│
╞══════════════╪═══════════════╪═══════════════╡
│"Commons Cafe"│"4"            │2              │
└──────────────┴───────────────┴───────────────┘