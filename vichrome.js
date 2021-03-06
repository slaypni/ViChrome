// Generated by CoffeeScript 1.3.3
(function() {
  var g, _ref;

  if ((_ref = this.vichrome) == null) {
    this.vichrome = {};
  }

  g = this.vichrome;

  setTimeout(function() {
    g.model.init();
    g.view = new g.Surface;
    g.handler = new g.EventHandler(g.model);
    return chrome.extension.sendRequest({
      command: "Init"
    }, function(msg) {
      return g.handler.onInitEnabled(msg);
    });
  }, 0);

  $(document).ready(function() {
    return g.model.onDomReady();
  });

}).call(this);
