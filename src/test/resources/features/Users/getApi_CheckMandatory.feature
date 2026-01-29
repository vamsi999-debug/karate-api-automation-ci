Feature: Check Mandatory Fields

Scenario: Verify Mandatory Checks


    * url 'https://gorest.co.in/public/v1/users'
    * method get 
    
    * def response = response.data
    * print response
    * def required =
      """
    {
        id: 'number',
        name: 'string',
        email : 'string',
        gender : 'string'

    }
    """
    * def validate =
    """
    function (list,keys){
        for(var i =0;i<list.length;i++){
            var item = list[i];
            for(var key in keys){
                var expectedType = keys[key];

                if(!item.hasOwnProperty(key)){
                    karate.fail("missing required keys" + karate.pretty(item))
                }

                var value = item[key];
                if(typeof value !=expectedType){
                    karate.fail("missing type" + "expected: "+expectedType + "actual:"+ typeof value)
                }
                if(value==null||value==' '){
                    karate.fail("no value assigned")
                }

            }
            

}    
    }
    """
    * eval validate(response,required)