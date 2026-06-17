/* 
Controls the sidebar behavior in the Shiny dashboard.
*/

$(document).ready(function () {
  var $body = $('body');
  var $sidebar = $('.main-sidebar');
  var $toggle = $('.sidebar-toggle');

  $toggle.add($sidebar).on('mouseenter', function () {
    if ($body.hasClass('sidebar-collapse')) {
      $body.removeClass('sidebar-collapse').addClass('sidebar-expanded-on-hover');
    }
  });

  $sidebar.on('mouseleave', function () {
    if ($body.hasClass('sidebar-expanded-on-hover')) {
      $body.removeClass('sidebar-expanded-on-hover').addClass('sidebar-collapse');
    }
  });

  $toggle.on('click', function () {
    $body.toggleClass('sidebar-collapse');
  });
});