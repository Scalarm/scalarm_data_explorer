// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//


//= require jquery
//= require jquery_ujs
//= require foundation
//= require custom.modernizr
//= require highcharts/highcharts
//= require highcharts/highcharts-more
//= require highcharts/highcharts-3d
//= require highcharts/modules/exporting
//= require toastr.min
//= require d3
//= require_tree .

$(function() {
    $(document).foundation();
    if(!navigator.userAgent.match(/Firefox|SeaMonkey/i))
        $(".nano").nanoScroller();

});

$(document).on("resize", function() {
    if(!navigator.userAgent.match(/Firefox|SeaMonkey/i))
        $(".nano").nanoScroller();
})

toastr.options = {
    "closeButton": true,
    "debug": false,
    "positionClass": "toast-top-right",
    "onclick": null,
    "showDuration": "3000",
    "hideDuration": "1000",
    "timeOut": "18000",
    "extendedTimeOut": "1000",
    "showEasing": "swing",
    "hideEasing": "linear",
    "showMethod": "fadeIn",
    "hideMethod": "fadeOut"
};

function string_with_delimeters() {
    var string_copy = this.split("").reverse().join("");
    var len = 3;
    var num_of_comas = 0;

    while ((len + num_of_comas <= string_copy.length) && string_copy.length > 3) {
        string_copy = string_copy.substr(0, len) + "," + string_copy.substr(len);
        num_of_comas = 1;
        len += 4;
    }

    return string_copy.split("").reverse().join("");
}

// Used to listen to invoke events for object only if it does not have 'disabled' class
function ignore_if_disabled(obj, fun) {
    if (obj.is('.disabled')) {
        return false;
    } else {
        return fun();
    }
}

$.prototype.enable = function () {
    $.each(this, function (index, el) {
        $(el).removeClass('disabled');
        $(el).removeAttr('disabled');
    });
};

$.prototype.disable = function () {
    $.each(this, function (index, el) {
        $(el).addClass('disabled');
        $(el).attr('disabled', 'disabled');
    });
};


function create_chart_div(method_name, id_chart) {
    if (method_name == 'lindev' || method_name == 'dendrogram')
        var method_chart_div = $("<div id=\"" + "chart_" + id_chart + "\">")[0];
    else
        var method_chart_div = $("<div id=\"" + method_name + "_chart_" + id_chart + "\">")[0];
    var chart_div = document.createElement('div');
    chart_div.className = 'chart';
    chart_div.style.marginLeft = '20%';
    chart_div.style.marginRight = '20%';
    chart_div.style.borderStyle = 'solid';
    chart_div.style.borderWidth = '1px';
    chart_div.style.borderColor = '#D8D8D8';
    chart_div.style.padding = '1.25rem';

    method_chart_div.appendChild(chart_div);
    $('body').append(method_chart_div);
}

String.prototype.with_delimeters = string_with_delimeters;
window.loaderHTML = '<div class="row small-1 small-centered" style="margin-bottom: 10px;"><img src="/assets/loading.gif"/></div>'