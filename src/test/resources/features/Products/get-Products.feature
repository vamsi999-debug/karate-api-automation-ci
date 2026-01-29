Feature: Working on Product Details

Background: 
    * url productsBaseUrl
    * path 'products'
    * method get
    * status 200
    * def response = response.products

Scenario: Schema Validation for Product Items

    # read SchemaFile
    * def itemSchema =  read('classpath:schemas/products/productItem.schema.json');
    #Asserting schema response
    * match each response contains itemSchema
    
Scenario: get Ratings >=4
    
    # Filter Procuts By Rating

    * def filterRatings =

    """
    function(data){
        return data.filter(p=>p.rating>4)
    }
    """

    #Asserting the Response 

    * def highRatedProducts = filterRatings(response)
    * print highRatedProducts
    * match each highRatedProducts[*].rating == '#?_> 4'

    Scenario: Get all review comments with rating 5
        * def getReviews =

        """
        function(response){
            var out =[]
            for( var i =0; i<response.length;i++){
                var reviews = response[i].reviews||[]
                var filtered= reviews.filter(p=> p.rating==5)
                out = out.concat(filtered)
            }
            return out

        }
        """

        #Asserting the Response 
        * def fiveStarReviews = getReviews(response)
        * print fiveStarReviews
        * assert fiveStarReviews.length > 0
        * match each fiveStarReviews[*].rating ==5


      Scenario: GET PRODUCTS BY MULTIPLE CONDITIONS
        * def requiredTags = ['beauty','face powder','nail polish']
        * def multipleProducts =
        """
        function(data,tags){
            return data.filter(p=> p.category=='beauty'&& p.rating > 4 && tags.some(t => p.tags.includes(t)))
        }
        """
        * def multiProdcuts = multipleProducts(response,requiredTags)
        * print multiProdcuts
        * match each multiProdcuts[*].tags == '#? _.some(t => requiredTags.includes(t))'
      
      Scenario: Extract All Product Titles where The Average Review rating is ≥ 4

        * def getAverageReview =
        """
        function(data){
            var out =[]
          
            for( var i =0; i<data.length;i++){
                var reviews = data[i].reviews;
                  var sum=0;
                for( var j = 0;j<reviews.length;j++){
                    var ratings = reviews[j].rating;
                    sum = sum+ratings;
                    
                }
                var average = sum/reviews.length
                if(average>4){
                    out.push({id:data[i].id,title:data[i].title,rating:data[i].rating,average:average})
                }

            }
            return out
        }
        """
        * def averageReview = getAverageReview(response)
        * print averageReview
        
      Scenario: Validate availability status against stock levels

        * def getStockStatus = 
        """
       function(response){

        return response.filter(t => t.availabilityStatus =='Low Stock')

       }

        """
        * def stockAvilability = getStockStatus(response)
        * print stockAvilability
        * match each  stockAvilability[*].stock == '#? _<=10'

        Scenario: Verify Discounted Price Validation

           * def verifyPriceDiscount =
           """
           function(data){
            var discountedPrice = data.price -(data.price * data.discountPercentage/100)
            return discountedPrice
           }
           """
           # Asserting the DiscountPrice less than Original Price
           * match each response == '#? verifyPriceDiscount(_) < _.price'
           
