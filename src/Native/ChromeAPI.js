Elm.Native.ChromeAPI = {};
Elm.Native.ChromeAPI.make = function(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.ChromeAPI = localRuntime.Native.ChromeAPI || {};
    if (localRuntime.Native.ChromeAPI.values)
    {
        return localRuntime.Native.ChromeAPI.values;
    }

    var Task = Elm.Native.Task.make(localRuntime);
    var Result = Elm.Result.make(localRuntime);
    var Utils = Elm.Native.Utils.make(localRuntime);

    function tabsQuery (queryInfo) {
        console.log(queryInfo);
        console.log(JSON.parse(queryInfo));

        return Task.asyncFunction(function(callback){
            chrome.tabs.query(JSON.parse(queryInfo), function(tabs) {
                console.log('tabs');
                console.log(tabs);
                return callback(Task.succeed(JSON.stringify(tabs)));
            });
        });
    }


	function log(string)
	{
		console.log('log');
		console.log(string);
		return Task.asyncFunction(function(callback) {
			console.log(string);
			return callback(Task.succeed(Utils.Tuple0));
		});
	}

    return localRuntime.Native.ChromeAPI.values = {
        log : log,
        tabsQuery : tabsQuery
    };
};
