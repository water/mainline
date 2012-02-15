/**
*Seven Color Picker 1.1.0
*Author: Seven Yu
*E-mail: dofyyu#gmail.com
*License: Same as jQuery
*Modifications: Slightly different event handling
**/
jQuery.fn.SevenColorPicker = function()
{
	var _SCP_FLAG          = '_I_AM_SCP';
	var _SCP_NUMS_PRE_LINE = 8;   // æ¯è¡Œæ˜¾ç¤ºé¢œè‰²ä¸ªæ•°
	var _SCP_ITEM_SIZE     = 15;  // è‰²å—å¤§å°
	var _SCP_ITEM_OFFSET   = 2;   // è‰²å—é—´è·
	var _SCP_OFFSET        = 3;   // é¢æ¿é—´è·
	var _SCP_BORDER_WIDTH  = 1;   // è¾¹æ¡†å®½åº¦
    var _SCP_COLORS        = ['ff8080','ffff80','80ff80','00ff80','80ffff','0080ff','ff80c0','ff80ff',
							  'ff0000','ffff00','80ff00','00ff40','00ffff','0080c0','8080c0','ff00ff',
							  '804040','ff8040','00ff00','008080','004080','8080ff','800040','ff0080',
							  '800000','ff8000','008000','008040','0000ff','0000a0','800080','8000ff',
							  '400000','804000','004000','004040','000080','000040','400040','408080',
							  '000000','808000','808040','808080','408080','c0c0c0','400040','ffffff'];
    if(!jQuery.SCP_Selecter)
    {
        var html = '<div><ul>';
        var result = jQuery('<div id="_seven_color_selecter" />');
        for(var c in _SCP_COLORS)
            html += '<li><a href="javascript:void(\'#'+_SCP_COLORS[c]+'\');" ref="#'+_SCP_COLORS[c]+'" style="background-color:#'+_SCP_COLORS[c]+';"></a></li>';
		html += '</ul><form style="margin:0;padding:3px;clear:both;text-align:center;">'+
                'HEX: <input id="_seven_color_code" maxlength="7" size="10" style="font:10px verdana" /> '+
                '<input type="submit" value=" OK " style="font:10px verdana" /></form></div>';
        result.html(html);
        $(document).mouseup(function(e){
            if (e.target.id != "_seven_color_code") result.hide();
        }).find('body').append(result);
        var setColor = function(col)
        {
            if(/^#?([0-9a-f]{3}|[0-9a-f]{6})$/i.test(col))
            {
                col = col.charAt(0) == '#' ? col : '#' + col;
                jQuery.SCP_Active.css('background-color',col);
                jQuery.SCP_Target.val(col);
            }
        }
        result.hide().css({'position':'absolute','font':'10px verdana','margin':0,'padding':0})
        .find('div').css({'background-color':'#f2f2f2','border':_SCP_BORDER_WIDTH+'px solid #999','margin':0,'padding':_SCP_OFFSET})
        .width(_SCP_NUMS_PRE_LINE*(_SCP_ITEM_SIZE+_SCP_ITEM_OFFSET*2+_SCP_BORDER_WIDTH*2))
        .find('form').submit(function()
        {
            setColor($(this).children('#_seven_color_code').val());
            jQuery.SCP_Selecter.hide();
            return false;
        }).end()
        .find('ul').css({'margin':0,'padding':0,'list-style':'none'})
        .find('li').css({'margin':0,'padding':0,'float':'left'})
        .find('a').css({'margin':_SCP_ITEM_OFFSET,'padding':0,'display':'block','border':_SCP_BORDER_WIDTH+'px solid #ccc'})
        .width(_SCP_ITEM_SIZE).height(_SCP_ITEM_SIZE)
        .mouseover(function(){$('#_seven_color_code').val($(this).attr('ref')).focus().select();})
        .mousedown(function(){setColor($(this).attr('ref'));})
        .mouseover(function(){$(this).css({'border':_SCP_BORDER_WIDTH+'px solid #333'});})
        .mouseout(function(){$(this).css({'border':_SCP_BORDER_WIDTH+'px solid #ccc'});});
        jQuery.SCP_Selecter = result;
        if(jQuery.browser.msie && jQuery.browser.version == '6.0')
            result.find('div').before('<iframe frameborder="0" width="'+result.width()+'" height="'+result.height()+'" style="position:absolute;z-index:-1;"></iframe>');
    }
    return this.each(function()
    {
		var myPicker = $(this).next(':text');
		if(myPicker.attr('ref') != _SCP_FLAG)
		{
			$(this).hide().after(
                $('<input ref="'+_SCP_FLAG+'" />')
                .width(_SCP_ITEM_SIZE).height(_SCP_ITEM_SIZE)
                .click(function()
                {
                    var offset = $(this).offset();
                    var left = offset.left;
                    var top  = offset.top+$(this).height()+_SCP_BORDER_WIDTH;
                    jQuery.SCP_Target = $(this).prev();
                    jQuery.SCP_Active = $(this);
                    jQuery.SCP_Selecter.show().css({'left':left,'top':top}).find('#_seven_color_code').val(jQuery.SCP_Target.val()).focus().select();
                }).attr('readonly','true')
                .css({'border':_SCP_BORDER_WIDTH+'px solid #999','cursor':'pointer','padding':0,'background-color':$(this).val()})
            );
		}
    });
}
