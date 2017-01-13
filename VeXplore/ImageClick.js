document.addEventListener('click', function (e)
{
	if (e.target.nodeName.toUpperCase() == 'IMG')
	{  
		location.href = 'https://' + '/special_tag_for_image_tap_vexplore/' + e.target.offsetLeft + '/special_tag_for_image_tap_vexplore/' +  e.target.offsetTop + '/special_tag_for_image_tap_vexplore/' +  e.target.clientWidth + '/special_tag_for_image_tap_vexplore/' +  e.target.clientHeight + '/special_tag_for_image_tap_vexplore/' + e.target.attributes['image_cache_key'].value
	}
});
