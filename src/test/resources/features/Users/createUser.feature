Feature: Users Registartion

Background:
    * url usersBaseUrl
    * path 'public', 'v2' , 'users'
    * headers usersHeader()

    #================================================
    #  HAPPY PATH (REUSABLE)
    #================================================

@createUser
Scenario: C38 Create user (reusable)
  # pass whatever came in; if nothing came, __arg is empty and factory uses defaults
  * def args = karate.get('__arg', {})
  * def build = call read('classpath:features/helpers/userPayloadFactory.feature@payloadFactory') args
  * def payload = build.result.payload

  Given request payload
  When method post
  Then status 201

  * def result = response
  * match result.id == '#number'
  * match result.name == build.result.name
  * match result.email == build.result.email

Scenario Outline: Create User registartion with gender =<gender> status =<status>

  * def created = call read('classpath:features/Users/createUser.feature@createUser') { gender: '<gender>', status: '<status>' }
  * match created.result.gender == '<gender>'
  * match created.result.status == '<status>'

Examples:
| gender | status |
| female | active |
| male   | active |


 Scenario: Duplicate email should fail

  * def created = call read('classpath:features/Users/createUser.feature@createUser')
  * print created.response
  * def email = created.response.email
  * def payload =
   """
   {
      name: 'Valid User',
      email:#(email),
      gender: #(created.response.gender),
      status: #(created.response.status)
   }
   """
  * request payload
  * method post
  * status 422
  * match response[*].message contains 'has already been taken'


   Scenario Outline: Missing <field> should fail with validation error

  * def build = call read('classpath:features/helpers/userPayloadFactory.feature@payloadFactory')

      # copy base payload

  * def clone =
"""
function(obj){
  return JSON.parse(JSON.stringify(obj));
}
"""
  * def payload = clone(build.result.payload)

  * remove payload.<field>
  * request payload
  * method post
  * status 422
  * match response[*].field contains '<field>'
  * match each response[*].message contains "can't be blank"

   Examples:
   |field|
   |name|
   |email|
   |gender|
   |status|


   Scenario Outline: Validate Mandatory Field <field> with invalid input

  * def build = call read('classpath:features/helpers/userPayloadFactory.feature@payloadFactory')
  * def clone =
   """
   function(data){
      return JSON.parse(JSON.stringify(data))
   }
   """
  * def payload = clone(build.result.payload)

   # set inavalid data for exisiting field
  * set payload.<field> = <badValue>
  * request payload
  * method post
  * status 422
  * match response[*].field contains '<field>'
  * match each response[*].message contains "can't be blank"

   Examples:
| field  | badValue |
| name   | ''       |
| name   | '   '    |
| name   | null     |
| email  | ''       |
| email  | '   '    |
| email  | null     |
| gender | ''       |
| gender | '   '    |
| gender | null     |
| status | ''       |
| status | '   '    |
| status | null     |


   Scenario Outline: Validate The Email Field with Invalid Format <email>

  *  def build = call read('classpath:features/helpers/userPayloadFactory.feature@payloadFactory')
  * def clone =
   """
   function(data){
      return JSON.parse(JSON.stringify(data))
   }
   """
  * def payload = clone(build.result.payload)
  * set payload.email = '<email>'
  * request payload
  * method post
  * status 422
  * match response[*].field contains 'email'
  * match each response[*].message contains 'is invalid'

 Examples:
| email           |
| testgmail.com   |
| test@           |
| @gmail.com      |
| test@.com       |




