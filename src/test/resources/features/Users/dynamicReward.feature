Feature: Product Details

Background:
    * url 'https://dummyjson.com/products'

Scenario: Get all products with rating ≥ 4
    
    * method get
    * status 200
    * def response = response.products
    * print response
    * def validate =
    """
    function(data){
        data.filter(p=>p.rating>=4)
    }
    """
    * eval validate(response)


Scenario: Get all review comments with rating 5

* method get
* status 200
* def response = response.products
* def validate =
"""
function(data){
for(var i=0;i<data.length;i++){
    var out=[]
    var reviews= data[i].reviews
    var filtered =reviews.filter(p=>p.rating>=5)
    out=out.concat(filtered)
}
return out
}


"""
* eval validate (response)

Scenario: Get products containing specific tags (ex: "beauty", "fruits")
    * method get
    * status 200
    * def response = response.products
    * def beautyProducts = response.filter(p => p.tags && p.tags.includes('beauty'))
* print beautyProducts

Scenario: Get specific reviewer names
    * method get
    * status 200
    * def response = response.products
    * def reviewerNames =
    """
    function(data){
        var names =[]
        for(var i =0;i<data.length;i++){
            
    var reviews = data[i].reviews
    var filtered= reviews.filter(p=> p.rating>=4)
    names = names.concat(filtered.map(r=>r.reviewerName))

        }
        return names
    }
    """
* def result = reviewerNames(response)
* print result

Scenario: GET PRODUCTS BY MULTIPLE CONDITIONS
    * method get
    * status 200
    * def response = response.products
    * def filter = response.filter(p=> p.category=='beauty'&& p.rating>=4 &&p.tags.includes('beauty'));
    * print filter

Scenario: extract all product titles where the average review rating is ≥ 4
    * method get
    * status 200
    * def response = response.products
    * def validate =
    """
    function(data){
        
        var out=[]
        for(var i =0; i<data.length;i++){
            var r = data[i]
            var reviews = r.reviews
            var sum =0
            for(var j =0;j<reviews.length;j++){
                sum = sum+reviews[j].rating
}
var average = sum/reviews.length

                if(average>=4){
                    out.push({id:r.id,title:r.title,rating:r.rating ,AvgReview:average})
                }
            
            
           
        }
        return out
 
    }
    """

    * def result = validate(response)
    * print result


Scenario: GET USERS AND FILTER ALL USERS WITH A VERIFIED EMAIL
    * url 'https://gorest.co.in/public/v1/users'
    * method get
    * status 200
    * def response = response.data
    * def emailPattern =
    """
    function(data){
        var pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        return data.filter(p=> pattern.test(p.email)&& p.status=='active')
    }
    """
    * def result = emailPattern(response)
    * print result

        Scenario: GET USERS AND EXTRACT ONLY ACTIVE FEMALES WITH AT LEAST ONE “A” IN NAME

        * url 'https://gorest.co.in/public/v1/users'
        * method get
        * status 200
        * def response = response.data
        * def validate =
        """
        function(data){
            return data.filter(p=> p.gender=='female' &&  p.status=='active' && p.name.includes("a")).map(p=> p.name)
        }
        """

        * def result = validate(response)
        * print result

        Scenario: Get Products
            * method get
            * status 200
            * def response = response.products
            * def validate =
            """
            function(data){
                var out =[]
            for(var i =0; i<data.length;i++)
{
             var p = data[i]
             var discountPrice = p.price-(p.price*p.discountPercentage/100)
             if(p.price>discountPrice){
                out.push({title:p.title,price:p.price,discountPrice:discountPrice})
             }

}  
     
   return out   
 }
      """        
           * def discounted = validate(response)
           * print discounted

           * def verifyPriceCheck =
           """
           function(response){
           return response.map(a=> a.discountPrice<a.price)
        }
           
           """
            * def flags = verifyPriceCheck(discounted)
            * match each flags == true

        Scenario: Get Dynamic Reward by mocking the current API response

            * method get
            * status 200
            * def response = response.products

            * def normalize = 

            """
            function(data){
                var out = []
                for( var i =0;i<data.length;i++){
                    var p = data[i]
                    out.push(
                        {ProductID: p.id,
                            "feature Id": p.category,
                            Type: p.discountPercentage>0 ?"Rewards":"Offer",
                            reward_info: {
                                reward_amount: p.discountPercentage,
                                currency: "USD"
                        },
                        spend_info: { "spend amount": p.price, currency: "USD" }
        }
                    )
                

                }
            return out

            }
            """

            * def result = normalize(response)
            * print result
            
            * def validateReward = 
            """
            function(data,ProductID,featureId,type,spendAmount,expectedRewardAmount){
                for(var i =0;i<data.length;i++){
                    
                }

            }
            """

            