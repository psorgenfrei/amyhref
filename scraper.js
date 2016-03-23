// From https://github.com/ariya/phantomjs/issues/10389

var page;
var timer;

var system = require('system');
var myurl = system.args[1];

var renderPage = function (url) {
  url = url.trim();
  page = require('webpage').create();
  page.settings.resourceTimeout = 10000;

  clearTimeout(timer)
  timer = setTimeout(function() { endProcess(); }, 5000);

  page.onNavigationRequested = function(url, type, willNavigate, main) {
    if (main && url != myurl) {
      myurl = url;
      console.log(myurl)
      page.close()

      //setTimeout('renderPage(myurl)',1); // recurse
      setTimeout(function() { renderPage(myurl); }, 1 ) // recurse
    }
  };

  page.open(url, function(status) {
    if (status === 'success') {
      page.close();
      phantom.exit(0);
    } else {
      page.close();
      phantom.exit(1);
    }
  });

  page.onError = function(msg, trace) {
    page.close();
    phantom.exit(1);
  }

  page.onResourceTimeout = function(request) {
    console.log('Response (#' + request.id + '): ' + JSON.stringify(request));
    //phantom.exit(1);
  }
} 

function endProcess() {
  clearTimeout(globalTimer);
  page.close();
  phantom.exit(1);
}

// Set a timer before we start, just to be sure
var globalTimer = setTimeout(function() { endProcess(); }, 6000);

renderPage(myurl);
