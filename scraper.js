// From https://github.com/ariya/phantomjs/issues/10389

var page;

var system = require('system');
var myurl = system.args[1];

var renderPage = function (url) {
    url = url.trim();
    page = require('webpage').create();
    var timer = setTimeout(function() { endProcess(); }, 10000);

    page.onNavigationRequested = function(url, type, willNavigate, main) {
        if (main && url!=myurl) {
            myurl = url;
            page.close()

            clearTimeout(timer)
            //setTimeout('renderPage(myurl)',1); // recurse
            setTimeout(function() { renderPage(myurl); }, 1 ) // recurse
            console.log(url)
        }
    };

    page.open(url, function(status) {
        if (status==='success') {
            phantom.exit(0);
        } else {
            phantom.exit(1);
        }
    });
} 

function endProcess() {
  phantom.exit(0);
}

renderPage(myurl);
