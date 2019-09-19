HTMLWidgets.widget({

  name: 'vue',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance
    var app = {};
    Vue.config.devtools = true;

    return {

      renderValue: function(x) {
        if (x.html !== ""){
          el.innerHTML = x.html;
        }
        // x.app.el = "#" + el.id;
        app = new Vue(x.app);
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      },

      getApp: function(){
        return(app);
      }

    };
  }
});

function get_vue_app(id){

  var htmlWidgetsObj = HTMLWidgets.find("#" + id);

  var app;

  if (typeof htmlWidgetsObj != 'undefined') {
    app = htmlWidgetsObj.getApp();
  }

  return(app);
}

if (HTMLWidgets.shinyMode) {
  Shiny.addCustomMessageHandler('updateProp',
    function(message) {
     console.log(JSON.stringify(message));
     // var app = HTMLWidgets.find("#" + message.id).getApp();
     var app = get_vue_app(message.id);
     var data = message.data;
     if (typeof app != 'undefined'){
       message.data.map(d => app[d.name] = d.value);
     }
  });
}
