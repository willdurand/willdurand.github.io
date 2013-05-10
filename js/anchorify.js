/*!
 * William DURAND <william.durand1@gmail.com>
 * MIT Licensed
 */
(function(b){var a;a=function(g){var d,f,c,e;c=g.text||"¶";e=g.cssClass||"anchor-link";d=g.$el.text().trim().replace(/[ ;,.'?!_]/g,"-").replace(/[-]+/g,"-").replace(/-$/,"").toLowerCase();f=['<a href="#',d,'" class="',e,'">',c,"</a>"].join("");g.$el.attr("id",d);g.$el.append(f)};b.fn.anchorify=function(c){c=c||{};this.each(function(){var d=b.extend({},c,{$el:b(this)});new a(d)});return this}})(jQuery);