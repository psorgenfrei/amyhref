// From https://github.com/ariya/phantomjs/issues/10389

var page;
var timer;

var system = require('system');
var myurl = system.args[1];

var renderPage = function (url) {
  url = url.trim();
  page = require('webpage').create();

  clearTimeout(timer)
  timer = setTimeout(function() { endProcess(); }, 5000);

  page.onNavigationRequested = function(url, type, willNavigate, main) {
    //console.log('Trying to navigate to: ' + url);
    //console.log('Caused by: ' + type);
    //console.log('Will actually navigate: ' + willNavigate);
    //console.log('Sent from the page\'s main frame: ' + main);

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
      phantom.exit(0);
    } else {
      phantom.exit(1);
    }
  });
} 

function endProcess() {
  //console.log('terminated')
  //return false;
  phantom.exit(1);
}

renderPage(myurl);
