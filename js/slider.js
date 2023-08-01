/*
slider.js
Javascript file for regulating the content-slider. 
Requires jQuery to function. 
*/
document.addEventListener('DOMContentLoaded', function() {
  const slider = document.getElementById('content-slider');
  slider.addEventListener('mouseover', (_ev) => {
    const sliderButtonForward = document.getElementById('slider-button-forward');

  });
});
$(document).ready(function()
{
	$("#content-slider").hover(function()
	{
		$("#slider-button-forward").fadeToggle("fast");
		$("#slider-button-back").fadeToggle("fast");
	});
	slidercounter = 1;
	$("#slider-button-forward").click(function()
	{
		$("#slide"+slidercounter).fadeToggle("slow");
		slidercounter = ((slidercounter - 1) % 3 + 1) % 3 + 1;
		$("#slide"+slidercounter).fadeToggle("slow");
	});
	$("#slider-button-back").click(function()
	{
		$("#slide"+slidercounter).fadeToggle("slow");
		slidercounter = (slidercounter + 1) % 3 + 1;
		$("#slide"+slidercounter).fadeToggle("slow");
	});
});
