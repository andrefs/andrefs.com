var tweetUser = 'work_andrefs';
var numTweets = '6';

$(document).ready(function(){

	$('#twitter-ticker').slideDown('slow');
	
	var fileref = document.createElement('script');
	
	fileref.setAttribute("type","text/javascript");
	searchURL = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name="+tweetUser+"&callback=TweetTick&count="+numTweets;
	fileref.setAttribute("src", searchURL);
	
	document.getElementsByTagName("head")[0].appendChild(fileref);
	
});

function TweetTick(ob)
{
	var container=$('#tweet-container');
	container.html('');
	container.attr('title','');
	
	$(ob).each(function(el){
	
		var str = '	<div class="tweet" title="'+relativeTime(this.created_at)+'"><i class="icon-chevron-right"></i> \
					<div class="txt">'+formatTwitString(this.text)+'</div>\
					</div>';
		
		container.append(str);
	
	});
	
}

function formatTwitString(str)
{
	str=' '+str;
	str = str.replace(/((ftp|https?):\/\/([-\w\.]+)+(:\d+)?(\/([\w/_\.]*(\?\S+)?)?)?)/gm,'<a href="$1" target="_blank">$1</a>');
	str = str.replace(/([^\w])\@([\w\-]+)/gm,'$1@<a href="http://twitter.com/$2" target="_blank">$2</a>');
	str = str.replace(/([^\w])\#([\w\-]+)/gm,'$1<a href="http://twitter.com/search?q=%23$2" target="_blank">#$2</a>');
	return str;
}

function relativeTime(pastTime)
{
	// Generate a JavaScript relative time for the tweets

	var origStamp = Date.parse(pastTime);
	var curDate = new Date();
	var currentStamp = curDate.getTime();
	var difference = parseInt((currentStamp - origStamp)/1000);

	if(difference < 0) return false;

	if(difference <= 5)			return "Just now";
	if(difference <= 20)			return "Seconds ago";
	if(difference <= 60)			return "A minute ago";
	if(difference < 3600)		return parseInt(difference/60)+" minutes ago";
	if(difference <= 1.5*3600) 	return "One hour ago";
	if(difference < 23.5*3600)	return Math.round(difference/3600)+" hours ago";
	if(difference < 1.5*24*3600)	return "One day ago";

	// If the tweet is older than a day, show an absolute date/time value;

	var dateArr = pastTime.split(' ');

	return dateArr[3].replace(/\:\d+$/,'')+' '+dateArr[2]+' '+dateArr[1]+
	(dateArr[5]!=curDate.getFullYear()?' '+dateArr[5]:'');
}
