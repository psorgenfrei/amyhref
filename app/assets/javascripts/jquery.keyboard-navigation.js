/*
 * jQuery Keyboard Navigation Plugin.
 * Copyright 2014, Anton Kulakov.
 * Dual licensed under the MIT or GPL Version 2 licenses.
 *
 * Project homepage: https://github.com/kulakowka/jquery-keyboard-navigation
 * 
 */

(function( $ ) {
 
    $.fn.keyboardNavagation = function(options) {

        var settings = $.extend({
            itemSelector: null,      
            selectedClass: 'selected',     
            offset: 0,                  // vertical offset
            onScrollPrev: function(element){},
            onScrollNext: function(element){}
        }, options );

        var Scroller = {
            
            container: this,
            
            currentSelectedElement: null,

            init: function(){
                this.container.on('scrollNext', $.proxy( this.scrollToNext, this ));
                this.container.on('scrollPrev', $.proxy( this.scrollToPrev, this ));
            },
            // Set scroll to next element
            scrollToNext: function(){
                
                var element = this.findFirstElementAfterScreenTop();
                
                if( settings.onScrollNext(element) !== false){
    
                    this.scrollToElement(element);

                }
            },

            // Set scroll to previous element
            scrollToPrev: function(){
                
                var element = this.findFirstElementBeforeScreenTop();
                
                if( settings.onScrollPrev(element) !== false){

                    this.scrollToElement(element);
                    
                }
            },

            /**
             * Scroll window to element
             * @param  {object} element jQuery element
             */
            scrollToElement: function(element){
                if(element){
                    $(window).scrollTop( element.offset().top + settings.offset );
                    this.setSelectedElement(element);
                }
            },

            /**
             * set current Element to selected mode
             * @param {object} element jquery-object with element
             */
            setSelectedElement: function(element){
                // remove selected class from last element
                if(this.currentSelectedElement && this.currentSelectedElement.length) {
                    this.currentSelectedElement.removeClass(settings.selectedClass);
                }
                // save last selected element
                this.currentSelectedElement = element;
                // add class to element
                element.addClass(settings.selectedClass);
                // fire event 'selected'
                element.trigger('selected');  
            },


            /**
             * Return all elements
             * @return {object} array of DOM jquery objects
             */
            getAllElements: function(){

                var elements;

                if(settings.itemSelector !== null) {
                    elements = this.container.find(settings.itemSelector);
                }else{
                    elements = this.container.children();
                }

                return elements;

            },

            /**
             * Return first element 
             * @return {object} element object
             */
            findFirstElementBeforeScreenTop: function(){

                var element = null,
                    elements = this.getAllElements(),
                    scroll_top = window.pageYOffset;

                var elements = elements.get().reverse();

                // get last element
                $.each(elements, function(){

                    element = $(this);
                    
                    if(element.offset().top + settings.offset < scroll_top){
                        return false; // break each;
                    }

                })

                return element;

            }, 
            
            /**
             * Return last element
             * @return {object} element object
             */
            findFirstElementAfterScreenTop: function(){
                
                var element = null,
                    elements = this.getAllElements(),
                    scroll_top = window.pageYOffset;

                // get first element
                elements.each(function(){

                    element = $(this);

                    if(element.offset().top  + settings.offset - 1 > scroll_top){
                        return false; // break each;
                    }

                })

                return element;
            }

        };

        // Start Scroller
        Scroller.init();

    };
 
}( jQuery ));