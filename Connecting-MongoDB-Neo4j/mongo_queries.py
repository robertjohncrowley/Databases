from pymongo import MongoClient
import operator

client = MongoClient()
db = client.test
coll = db.restaurants

count = db.restaurants.find().count()

pop_cuisine = ""
pop_cuisine_num = 0
borough = ""
zipcode = ""

def most_popular_cuisine(db):
    global count, pop_cuisine, pop_cuisine_num

    query = [{"$group":{"_id":"$cuisine","count":{"$sum":1},"data":{"$push":"$$ROOT"}}},
                {"$sort":{"count":-1}},{"$limit":1},{"$unwind":"$data"},
                {"$group":{"_id":{"cuisine":"$data.cuisine"},"count":{"$sum":1}}},
                {"$project":{"count":1,"percentage":{"$multiply":[{"$divide":[100,count]},"$count"]}}}]

    cuisine = db.restaurants.aggregate(query)
    for doc in cuisine:
        pop_cuisine = doc.get("_id").get('cuisine')
        pop_cuisine_num = doc.get("count")

    print("Query 1\nCuisine:", pop_cuisine, "\nCount:", pop_cuisine_num, "Restaurants\nPercentage:", round(doc.get("percentage"),2), "%")

def ratio_per_borough_and_cuisine(db, cuisine):
    global pop_cuisine_num, borough
    query = [{"$group":{"_id":"$borough","count":{"$sum":1}}}]
    
    borough_a = db.restaurants.aggregate(query)
    total_restaurant_count = {}
    for doc_a in borough_a:
        total_restaurant_count[doc_a.get("_id")] = doc_a.get("count")

    query1 = [{"$match":{"cuisine" : cuisine}},
              {"$group":{"_id" : "$borough","count":{"$sum":1}}}]
    
    borough_b = db.restaurants.aggregate(query1)
    
    restaurant_count = {}
    for docA in borough_b:
        restaurant_count[docA.get("_id")] = docA.get("count")
    keys = restaurant_count.keys()
    boroughDict = {}
    for key in keys:
        a = restaurant_count.get(key)
        total = (a/pop_cuisine_num)*100
        boroughDict[key] = total
    
    boroughDictA = sorted(boroughDict.items(), key=operator.itemgetter(1))
    
    borough = boroughDictA[1][0]
    print("\nQuery 2 \nBourough:",boroughDictA[1][0],"\nPercentage:",round(boroughDictA[1][1],2),"%")

def ratio_per_zipcode(db, cuisine, borough):
    global zipcode
    query = [{"$match":{"borough": borough}},{"$group":{"_id":"$address.zipcode","count":{"$sum":1}}},
              {"$sort":{"count":1}},{"$limit":5}]
    most_pop_zips = db.restaurants.aggregate(query)

    zipcode = ""
    rest_count = 0
    # gets first zipcode
    for doc in most_pop_zips:
        zipcode = doc.get("_id")
        rest_count = doc.get("count")
        break
    queryB = [{"$match":{"$and":[{"cuisine": cuisine}, {"borough": borough}]}}, {"$group":{"_id":"$address.zipcode","count":{"$sum" : 1}}},
              {"$sort":{"count" : 1}},{"$limit" : 5}]
    cuis_zips = db.restaurants.aggregate(queryB)

    total_in_zip = 0
    for doc in cuis_zips:
        total_in_zip += doc.get("count")

    print("\nQuery 3 \nZipcode:",zipcode, "\nAmerican Restaurants:", rest_count,"\nPercentage:", round(rest_count/total_in_zip,2),"%")

def best_restaurants(db, cuisine, borough, zipcode):
    [{"$match": {"$and": [{"cuisine": cuisine}, {"borough": borough}]}},
     {"$group": {"_id": "$address.zipcode", "count": {"$sum": 1}}},
     {"$sort": {"count": 1}}, {"$limit": 5}]


    query = [{"$match": {"$and":[{"address.zipcode": zipcode}]}},
              {"$group": {"_id": "$name", "count": {"$sum": 1}}},
              {"$sort": {"count": 1}}, {"$limit": 5}]
    rest = db.restaurants.aggregate(query)

    name = ""
    for doc in rest:
        name = doc.get("_id")

    query_b = [{"$match": {"$and":[{"name": name}]}},
              {"$group": {"_id": "$grades.score"}},
              {"$sort": {"count": 1}}, {"$limit": 5}]
    reviews = db.restaurants.aggregate(query_b)

    scores = []
    for dic in reviews:
        scores = dic.get("_id")

    print("\nQuery4\nName:",name,"\nTotal Reviews:",len(scores),"\nAverage Score:",sum(scores)/len(scores))

most_popular_cuisine(db)
ratio_per_borough_and_cuisine(db, pop_cuisine)
ratio_per_zipcode(db, pop_cuisine, borough)
best_restaurants(db, pop_cuisine, borough, zipcode)