Feature: Read Json Values

Scenario: Read JSON

* def jsonObject =
"""
{
  "menu": {
    "id": "file",
    "value": "File",
    "popup": {
      "menuitem": [
        { "value": "New", "onclick": "CreateNewDoc()" },
        { "value": "Open", "onclick": "OpenDoc()" },
        { "value": "Close", "onclick": "CloseDoc()" }
      ]
    }
  }
}
"""

* def items = jsonObject.menu.popup.menuitem
* def allValues = karate.jsonPath(items,"$[*].value")
* print allValues


Scenario: Filter API response data
  * def apiResponse =
  """
  {
    success: true,
    data: {
      users: [
        { id: 1, name: 'Alice Johnson', role: 'admin', active: true },
        { id: 2, name: 'Bob Smith', role: 'user', active: true },
        { id: 3, name: 'Carol White', role: 'user', active: false }
      ]
    }
  }
  """

  * def getActiveUsers =
  """
  function(data){
    return data.filter(p => p.active ==true)
  }
  """
* def response = apiResponse.data.users
* print response
* def activeUsers = getActiveUsers(response)
* print activeUsers
* match karate.sizeOf(activeUsers) == 2
