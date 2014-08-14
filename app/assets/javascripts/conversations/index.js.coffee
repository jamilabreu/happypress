jQuery ->
	pusher = new Pusher("1023af61b2f6ec874e78")
	channel = pusher.subscribe("global_channel")
	channel.bind "update_conversations", (data) ->
		item = $(".item#" + data.id)
		first_item_id = $(".item.active").attr("id")
		item_class = "new"
		item_class += " unanswered"  if parseInt(data.count) is 0
		item_class += " active"  if parseInt(data.id) is first_item_id
		item.remove()
		$(".new-post-area").prepend "<div class=\"item " + item_class + "\" id=\"" + data.id + "\"><a data-remote=\"true\" href=\"/conversations/" + data.id + "\"><div class=\"item-count\"><span>" + data.count + "</span></div><div class=\"item-title\">" + data.title + "<div class='item-timeago'><abbr class='timeago' title='" + data.timeago + "'></div></div></a></div>"
		$("abbr.timeago").timeago()
		setTimeout (-> $(".item#" + data.id).removeClass "new"), 10000
	$(".post a").attr("target", "_blank")
	$("abbr.timeago").timeago()