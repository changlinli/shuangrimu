function highlighting(element)
{
	$(document).ready(function()
	{
		flag = false;
		if($(element).css("background-color") != 'rgb(220, 220, 220)') 
		{
			flag = true;
		}
		if(flag == true)
		{
		$(element).mouseenter(function()
		{
			$(element).css({"background-color":'rgb(220,220,220)'});
		});
		$(element).mouseleave(function()
		{
			$(element).css({"background-color":'rgb(255, 255, 255)'});
		});
		}
	});
}
