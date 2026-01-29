Feature: Common utilities

Scenario: utilities

# clone the payload
* def clone =
"""
function(obj){
    return JSON.parse(JSON.stringify(obj))
}
"""

# random String
* def randomString =
"""
function(prefix){
    return prefix + '_' + java.util.UUID.randomUUID() + ''
}
"""

# long string
* def longString =
"""
function(length){
    var str = ''
    for(var i =0;i<length;i++)
    str =str+ 'a'
     return str
}
"""

# updatePayload
* def createUserAndPrepareUpdatePayload =
"""
function () {
    var created = karate.call('classpath:features/Users/createUser.feature@createUser');

    var payload = clone(created.response);
    delete payload.id;
    return {
        created: created.response,
        payload: payload
    }
}
"""
