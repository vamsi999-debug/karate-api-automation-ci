Feature: Delete User

Background:

* url usersBaseUrl
* headers usersHeader()

@deleteUser
Scenario: Delete created user

    * def util = call read('classpath:features/helpers/commonUtils.feature')
    * def id = util.createUserAndPrepareUpdatePayload().created.id
    * path 'public', 'v2' , 'users' , id
    * method delete
    * status 204


