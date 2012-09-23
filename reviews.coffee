# Location epicenter.
location = "335 Madison Ave, New York 10016"

# Paths to the extension static files.
staticFiles =
  loading : chrome.extension.getURL 'images/loading.gif'
  star : chrome.extension.getURL 'images/full.gif'
  halfStar : chrome.extension.getURL 'images/half.gif'
  emptyStar : chrome.extension.getURL 'images/empty.gif'

# Return error message linked to Yelp manual search
getError = (err, restaurant_name) ->
  term = encodeURI restaurant_name
  href = "http://www.yelp.com/search?find_desc=#{term}&find_loc=#{location}&ns=1"

  $(document.createElement 'a').attr({ href: href, target: '_blank' }).html(err)

# Return div with Yelp rating and num reviews
getReviews = (rating, review_count, url) ->
  fullStarStr = ->
    return "<img src='#{staticFiles.star}' />"
  halfStarStr = ->
    return "<img src='#{staticFiles.halfStar}' />"
  emptyStarStr = ->
    return "<img src='#{staticFiles.emptyStar}' />"

  reviews = $(document.createElement 'a')
  reviews.attr { href: url, target: '_blank', class: 'num-reviews' }
  reviews.css { display: 'block', 'margin-top': '3px' }
  reviews.html "(#{review_count} reviews)"

  if rating?
    stars = (fullStarStr() for i in [0 ... Math.floor(rating)]).join('')
    stars += halfStarStr() if rating isnt Math.floor(rating)
    stars += (emptyStarStr() for i in [0 ... (5 - Math.ceil(rating))]).join('')
  else
    stars = "No Rating"

  return { stars: stars, reviews: reviews }



# Add a Yelp unit for every restaurant on the Seamless page.
$(document).ready ->
  $('td.rating').each ->
    $(this).append '<div class="yelp"><a class="button" href="#">Yelp It</a></div>'

  $('div.yelp a').bind 'click', ->
    button = $(this)
    div = button.parent()

    # Replace button text with loading indicator
    button.removeClass 'button'
    button.html "<img src='#{staticFiles.loading}' />"

    name = button.parents('tr').first().children('td.restaurant').find('a').html()
    if not name
      console.log 'No restaurant name for this table row?'
      return false

    xhr = new XMLHttpRequest
    xhr.open "GET", "https://seamless-yelp.herokuapp.com/?s=#{encodeURI(name)}", true
    xhr.onreadystatechange = ->
      if xhr.readyState is 4
        res = $.parseJSON xhr.responseText
        if res.error?
          err = getError(res.error, name)
          div.html err
          div.addClass 'yelp-err'
        else
          ratings = getReviews(res.rating, res.review_count, res.url)
          div.html ratings.stars
          div.append ratings.reviews
    xhr.send()

    return false
  # end onclick
