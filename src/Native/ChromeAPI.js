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
        return Task.asyncFunction(function(callback){
            chrome.tabs.query(JSON.parse(queryInfo), function(tabs) {
                return callback(Task.succeed(JSON.stringify(tabs)));
            });
        });
    }


    function log(string)
    {
        return Task.asyncFunction(function(callback) {
            return callback(Task.succeed(Utils.Tuple0));
        });
    }

    return localRuntime.Native.ChromeAPI.values = {
        log : log,
        tabsQuery : tabsQuery
    };
};
