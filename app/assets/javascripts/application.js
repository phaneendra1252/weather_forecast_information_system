// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree ./bootstrap

$(document).ready(function() {
  $('.form_date').datetimepicker({
    weekStart: 1,
    todayBtn:  1,
    autoclose: 1,
    todayHighlight: 1,
    startView: 2,
    minView: 2,
    forceParse: 0
  });

    $('form').on('click', '.remove_fields', function(event) {
      $(this).closest('.field').remove();
      return event.preventDefault();
    });

    $('form').on('click', '.add_fields', function(event) {
      var regexp, time;
      time = new Date().getTime();
      regexp = new RegExp($(this).data('id'), 'g');
      $(this).before($(this).data('fields').replace(regexp, time));
      return event.preventDefault();
    });

});

$(document).on('page:change', function () {
    $('.div1').width($('.panel-table').width());
    $('.panel-table').width($('.panel-table').width());

    $('.wrapper1').on('scroll', function (e) {
        $('.scroll-div').scrollLeft($('.wrapper1').scrollLeft());
    });
    $('.scroll-div').on('scroll', function (e) {
        $('.wrapper1').scrollLeft($('.scroll-div').scrollLeft());
    });
});