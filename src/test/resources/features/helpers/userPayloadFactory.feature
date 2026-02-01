Feature: User Payload Factory

@payloadFactory
Scenario: Build User PayLoad

    * def uuid = java.util.UUID.randomUUID() + ''
* def email = 'KarateUser_' + uuid + '@test.com'
    * def gender = karate.get('gender','male')
    * def status = karate.get('status', 'active')

    # get name based on gender
    * def name = gender =='female'?'Rani' + uuid : 'Vamsi' +uuid

    # read File
    * def payload = read('classpath:payloads/newUserPayload.json')

    # return PayLoad and all fields

    * def result =
      """
    {
        payload: #(payload),
        name: #(name),
        email: #(email),
        gender: #(gender),
        status: #(status)
    }
      """

