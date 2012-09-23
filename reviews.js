// full star image
var starImg = chrome.extension.getURL('images/star.png');
var starHalfImg = chrome.extension.getURL('images/star_half.png');

// Inject an error message into the Yelp It div.
var showError = function(errorMessage, name, div) {
  var yelpLink = "http://www.yelp.com/search?find_desc=" + encodeURI(name) + "&find_loc=335+madison+ave%2C+new+york+10016&ns=1";
  var a = $(document.createElement('a'))
    .attr({ href : yelpLink, target : "_blank"})
    .html(errorMessage);
  div.html(a);
  div.addClass("yelp-err");
};

// Inject the yelp rating into the Yelp It div.
var showResults = function(res, div) {
  var stars = $(document.createElement('div'));
  if (!res.rating) {
    stars.html("No Yelp ratings??");
  } else {
    // Some gross stuff to add the star images.
    for (var i = 0; i < Math.floor(res.rating); i++) {
      stars.append($(document.createElement('img')).attr("src", starImg));
    }
    if (res.rating != Math.floor(res.rating)) {
      // This should always mean a half-star, right..?
      stars.append($(document.createElement('img')).attr("src", starHalfImg));
    }
  }

  var reviews = $(document.createElement('a'))
    .attr({ href: res.url, target: "_blank"})
    .html("(" + res.review_count + " reviews)");
  div.html(reviews);
  div.prepend(stars);
};

$(document).ready(function() {

  // Add a Yelp It div after each rating button.
  var targets = [];
  $("td.rating").each(function() {
    var a = $(document.createElement('a')).attr("href", "#").html("Yelp It");
    var button = $("<div class='yelp yelp-button'></div>");
    targets.push(a);
    $(this).append(button.append(a));
  });

  // Add click target for added button.
  $(targets).each(function() {
    $(this).bind("click", function() {

      // $(this) is the <a> inside the div.
      var name = $(this).parents("tr").first().children("td.restaurant").find("a").html();
      if (!name) {
        console.log("Something went wrong. Couldn't find restaurant name for this button?");
        return false;
      }

      // Query our app, which queries Yelp API.
      var xhr = new XMLHttpRequest();
      var div = $(this).parent();
      xhr.open("GET", "http://seamlessyelp.herokuapp.com/?s="+encodeURI(name), true);
      xhr.onreadystatechange = function() {
        if (xhr.readyState == 4) {
          var res = $.parseJSON(xhr.responseText);
          if (res.error) {
            showError(res.error, name, div);
          } else {
            showResults(res, div);
          }
          div.removeClass("yelp-button");
        }
      };
      xhr.send();

      // Nullify <a> click.
      return false;
    });
  });
});