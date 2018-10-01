var premiumizeExtension = function() {};

premiumizeExtension.prototype = {
run: function(arguments) {
    arguments.completionFunction({"baseURI" : window.location.href});
},
finalize: function(arguments) {
    window.location.href = arguments["directDL"];
}
}

var ExtensionPreprocessingJS = new premiumizeExtension;
