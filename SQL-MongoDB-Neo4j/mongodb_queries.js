1. 	use bank
	db.staff.insert({ .... })
2. 	db.staff.find({$and:[{"eyeColor":"brown"},{"isActive":true}]}).pretty()
3. 	db.staff.find({$or:[{"eyeColor":"green"},{"isActive":true}]}).pretty()
4. 	db.staff.find({$and:[{"eyeColor":"blue"},{"balance":{$lte:1500}}]}).pretty()
5. 	db.staff.find({$or:[{"eyeColor":"green"},{"isActive":true}]}, {"name":1,"balance":1,"_id":0}).pretty()
6. 	db.staff.find({"age":{$gt: 30}}).limit(5).pretty()
	db.staff.find().skip(2).pretty()
7. 	db.staff.find().sort({"age":1}).limit(10).pretty()
8. 	db.staff.aggregate([{$group:{_id:"$gender",total:{$avg:"$balance"}}}]).pretty()
9.	db.staff.aggregate([{$group:{_id:"$eyeColor",averageGender:{$sum:1}}}]).pretty()
10	db.staff.find({balance:{$gt:3000}).explain()