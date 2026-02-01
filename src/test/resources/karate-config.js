function fn() {
    var config = {};
    
    // BaseUrls
    config.productsBaseUrl = 'https://dummyjson.com';
    config.usersBaseUrl = 'https://gorest.co.in';

     // optional token (only needed for POST/PUT/DELETE in GoREST)
    config.gorestToken = karate.properties['gorest.token'];
    
    // Header Function
    config.usersHeader = function () {
        if(!config.gorestToken){
            karate.fail(
                'AccessToken is Mandatory for (POST/PUT/DELETE) calls');
        }

        return {
            Authorization: 'Bearer ' + config.gorestToken,
            'Content-type': 'application/json'
        };
    };

    return config;
}