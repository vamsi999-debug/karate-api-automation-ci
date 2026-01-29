Feature:  Working on User Details

  Background:
    * url usersBaseUrl
    * headers usersHeader()

  Scenario: Verify user details after creation
    * def created = call read('classpath:features/Users/createUser.feature@createUser')
    * def id = created.response.id
    * path 'public', 'v2', 'users', id
    * print id
    * method get
    * status 200
    * match response.id == id
    * match response.name == created.response.name
    * match response.email == created.response.email
    * match response.gender == created.response.gender
    * match response.status == created.response.status


  Scenario: Get users and filter all users with a verified email

    * path 'public', 'v1', 'users'
    * method get
    * status 200
    * def response = response.data

    * def getVerifiedActiveUsers =
    """
    function (users) {
    var emailRegex = /^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/;

    return users.filter(user =>
    emailRegex.test(user.email) &&
    user.status === 'active'
    );
    }
    """

    * def activeUsers = getVerifiedActiveUsers(response)
    * print activeUsers
    * match each activeUsers[*].status =='active'

  Scenario: Get users and extract only active females with at least one "A" in the name

    * path 'public', 'v1', 'users'
    * method get
    * status 200
    * def response = response.data

                * def getActiveFemaleUsers =
                """
                function(data){
                    return data.filter(t =>t.gender=='female' && t.status =='active' && t.name.includes('A'))
                }
                """

                * def activeFemaleUsers = getActiveFemaleUsers(response)
                * print activeFemaleUsers
                * match each activeFemaleUsers[*].gender =='female'
                * match each activeFemaleUsers[*].status =='active'
                * match each activeFemaleUsers[*].name =='#? _.includes("A")'

  Scenario: Verify pagination details for users list

    * path 'public', 'v1', 'users'
    * method get
    * status 200
    * def pagination = response.meta.pagination
    * def users = response.data
    * def paginationSchema = read('classpath:schemas/users/paginationSchema.json')
    * match pagination == paginationSchema
    * match users == '#[]'
    * assert users.length <= pagination.limit
  Scenario: Verify users response schema validation

    * path 'public', 'v2', 'users'
    * method get
    * status 200
    * def usersResponseSchema = read('classpath:/schemas/users/userResponseSchema.json')
    * match each response == usersResponseSchema
  Scenario Outline: Users list should handle valid query parameters safely: <param>

    * path 'public', 'v2','users'
    * param <param> = '<value>'
    * method get
    * status 200
    * def paramName = '<param>'
    * def values = response.map(r => r[paramName])
     # string search filter
    * if(paramName == 'name'|| paramName == 'email') karate.match(values, '#[] #? _.toLowerCase().includes("<value>".toLowerCase())')
    # enumfilter
    * if(paramName == 'gender'|| paramName == 'status') karate.match(values, '<value>')

    Examples:
      |param      |value|
      |name       |Vamsi|
      |email      |@test.com|
      |gender     |male|
      |status     |active|
 Scenario Outline: Users list should handle invalid query parameters safely: <case>

    * path 'public', 'v2','users'
    * param <param> = '<value>'
    * method get
    * def statusCode = responseStatus
    # API May reject with (422/400) or return with empty/normal response
    * match statusCode == '#? _ ==200 || _ ==400 || _ ==422'
    * if (statusCode ==200) karate.match(response, '#[]')

    Examples:
      | case                     | param  | value        |
      | page_not_numeric          | page   | abc          |
      | page_special_chars        | page   | ???          |
      | page_negative             | page   | -1           |
      | page_zero                 | page   | 0            |
      | page_out_of_range         | page   | 999999       |
      | gender_invalid_enum       | gender | trans        |
      | status_invalid_enum       | status | unknown      |
      | email_invalid_format      | email  | not-an-email |

 Scenario: Validate deleted users

 * def deletedUser = call read('classpath:features/Users/deleteUser.feature@deleteUser')
  * def id = deletedUser.id
  * print id
  * path 'public', 'v2', 'users', id
  * method get
  * status 404
  * match each response[*].message contains 'Resource not found'





