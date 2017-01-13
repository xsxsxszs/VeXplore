
document.addEventListener('click', function (e)
{
	if (e.target.nodeName.toUpperCase() == 'IMG')
	{
		var href = location.href;
		href += encodeURI(e.target.src);
		location.href = href;
	}
});
