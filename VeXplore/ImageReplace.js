var imageNodes = document.getElementsByTagName("img")
for (var i = 0; i < imageNodes.length; i++)
{
    try {
        var $el = imageNodes[i].parentNode;
        var href = $el.getAttribute('href').split('/').pop();
        var src = imageNodes[i].getAttribute('src').split('/').pop();
        var imageCacheKey = imageNodes[i].getAttribute('image_cache_key').split('/').pop();
        if (href === src || href === imageCacheKey)
        {
            $el.setAttribute('href', 'javscript:void();');
        }
    } catch (err) {}

	if (imageNodes[i].getAttribute("image_cache_key") == "%@")
	{
		imageNodes[i].setAttribute("src", "%@")
	}
}
