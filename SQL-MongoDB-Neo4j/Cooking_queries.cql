** Question 1 has been appended to the end of the original script **

1.	(theCake:Cake {name: "The Cake", used: 20}),
  	(theCake)-[:CONTAINS {quantity: 25, unit: "grams"}]->(simple),
  	(theCake)-[:CONTAINS {quantity: .5, unit: "grams"}]->(lemonPeel),
  	(theCake)-[:CONTAINS {quantity: 125, unit: "grams"}]->(mixedpeel),
  
  	(juiceCake:Cake {name: "The Juice", used: 50}),
  	(juiceCake)-[:CONTAINS {quantity: 25, unit: "grams"}]->(tomatoJuice),
  	(juiceCake)-[:CONTAINS {quantity: .5, unit: "grams"}]->(lemonJuice),
  	(juiceCake)-[:CONTAINS {quantity: 125, unit: "grams"}]->(limeJuice),
  
  	(ringer:Cake {name: "The Ringer", used: 7}),
  	(ringer)-[:CONTAINS {quantity: 25, unit: "grams"}]->(butter),
  	(ringer)-[:CONTAINS {quantity: .5, unit: "grams"}]->(soda),
  	(ringer)-[:CONTAINS {quantity: 125, unit: "grams"}]->(spice),

	(bradley:chef {name:"Chef Bradley"}),
	(bradley)-[:OWNS ]->(theCake),
	(joey:chef{name:"Chef Joey"}),
	(joey)-[:OWNS ]->(juiceCake),
	(bonnie:chef{name:"Chef Bonnie"}),
	(bonnie)-[:OWNS ]->(ringer)

2.	MATCH(cake:Cake)-[:CONTAINS]->(ing:Ingredient) RETURN cake.name,ing.name
3.	MATCH(cake:Cake)-[:CONTAINS]->(ing:Ingredient)WHERE cake.name = "Brownies" RETURN ing.name as Brownies
4.	MATCH(cake:Cake)-->(flour:Flour) RETURN cake.name as Cakes
5.	MATCH(cake:Cake)-[:CONTAINS]->(ing:Ingredient)MATCH(cake:Cake)-[:CONTAINS]->(ingTwo:Ingredient)WHERE ing.name = "milk" AND ingTwo.name = "cream"RETURN cake.name
6. 	MATCH(chef:chef)-[:OWNS]->(cake:Cake) RETURN chef.name as chef, cake.name as cake
7. 	MATCH(chef:chef)-[o:OWNS]->(cake:Cake) RETURN chef.name as chef, cake.name as name ORDER BY o.used DESC
8.	MATCH(ing:Ingredient) RETURN ing.name,SIZE(()-[:CONTAINS]->(ing)) as used ORDER BY used DESC LIMIT 5
9.	MATCH(ing:Ingredient) WHERE SIZE(()-[:CONTAINS]->(ing)) > 0 RETURN ing.name,SIZE(()-[:CONTAINS]->(ing)) as used ORDER BY used LIMIT 5
10	MATCH(ing:Ingredient)<-[:CONTAINS]-(cake:Cake),(chef:chef) RETURN chef.name, ing.name,count((ing)<-[:CONTAINS]-()) as used ORDER BY used LIMIT 5
11.	MATCH (cake:Cake {name: 'Apple Scones'})-[:CONTAINS]->(ingeredient),(ingeredient)<-[:CONTAINS]-(cakeTwo:Cake) WHERE cake <> cakeTwo RETURN cakeTwo.name, collect(ingeredient.name) AS ingreds