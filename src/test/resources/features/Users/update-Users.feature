Feature: Update user details

Background:
    * url usersBaseUrl
    * headers usersHeader()

    # Shared setup: create user and prepare sanitized update payload (id removed)
    * def utils = call read('classpath:features/helpers/commonUtils.feature')
Scenario: Update single user detail after created

    * def createdUser = utils.createUserAndPrepareUpdatePayload()
    * def payload = createdUser.payload

    # Update user name
    * set payload.name = utils.randomString('chinni')
    * def responseSchema = read('classpath:schemas/users/userResponseSchema.json')

     # Update user using resource id
    * path 'public', 'v2' , 'users' , createdUser.created.id
    * request payload
    * method put
    * status 200

      # Validate updated and unchanged fields
    * match response == responseSchema
    * match response.name == payload.name
    * match response.email == createdUser.created.email
    * match response.id == createdUser.created.id
    * match response.gender == createdUser.created.gender
    * match response.status == createdUser.created.status


    Scenario: Update multiple user details after created

    * def createdUser = utils.createUserAndPrepareUpdatePayload()
    * def payload = createdUser.payload

    # Update email,gender,status values
    * set payload.email = utils.randomString('chinni') + '@test.com'
    * set payload.gender = createdUser.created.gender == 'female' ? 'male' : 'female'
    * set payload.status = 'inactive'

    # Update user using resource id
    * path 'public', 'v2' , 'users' , createdUser.created.id
    * request payload
    * method put
    * status 200

    # Validate updated and unchanged fields
    * assert response.email != createdUser.created.email
    * assert response.gender != createdUser.created.gender
    * assert response.status != createdUser.created.status
    * match response.name == createdUser.created.name
    * match response.email == payload.email
    * match response.gender == payload.gender
    * match response.status == payload.status
    * match response.id == createdUser.created.id

    Scenario: Update user should reject name longer than 200 characters

    * def createdUser = utils.createUserAndPrepareUpdatePayload()
    * def payload = createdUser.payload
    * def longName = utils.longString(201)

    # Update name with long string
    * set payload.name = longName

    # Update user using resource id
    * path 'public', 'v2' , 'users' , createdUser.created.id
    * request payload
    * method put
    * status 422

    # Validate field name and error response message
    * match  response[*].field contains 'name'
    * match each response[*].message contains 'is too long (maximum is 200 characters)'

    Scenario Outline: Update email field with invalid format <email>

    * def createdUser = utils.createUserAndPrepareUpdatePayload()
    * def payload = createdUser.payload

    # Update email with multiple invalid inputs
    * set payload.email = '<email>'

     # Update user using resource id
    * path 'public', 'v2' , 'users' , createdUser.created.id
    * request payload
    * method put
    * status 422

    # Validate field name and error response message
    * match  response[*].field contains 'email'
    * match each response[*].message contains 'is invalid'


 Examples:
| email           |
| testgmail.com   |
| test@           |
| @gmail.com      |
| test@.com       |










