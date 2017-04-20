var initialize_calendar;
initialize_calendar = function() {
  $('.calendar').each(function(){
    var calendar = $(this);
    calendar.fullCalendar({
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      selectable: true,
      selectHelper: true,
      editable: true,
      eventLimit: true,
      events: '/events/calendar.json',
      defaultView: 'agendaDay',
      minTime: "06:00:00",
      maxTime: "18:00:00",
      forceEventDuration: true,
      defaultTimedEventDuration: '00:15:00',
      slotDuration: '00:15:00',
      allDaySlot: false,
      businessHours: {
          // days of week. an array of zero-based day of week integers (0=Sunday)
          dow: [ 1, 2, 3, 4, 5, 6, 7 ], // Monday - Sunday
          start: '07:00', // a start time (7am in this example)
          end: '18:00' // an end time (6pm in this example)
        },
        
      select: function(start, end, jsEvent, view) {
        if (view.name !== 'month') { // Don't allow event creation from month view
          $.getScript('/events/new', function() {
            $('#event_date_range').val(moment(start).format("MM/DD/YYYY HH:mm") + ' - ' + moment(end).format("MM/DD/YYYY HH:mm"))
            //date_range_picker();
            $('.start_hidden').val(moment(start).format('YYYY-MM-DD HH:mm'));
            $('.end_hidden').val(moment(end).format('YYYY-MM-DD HH:mm'));
            $('#new_event_start').text(moment(start).format("MM/DD/YY h:mm A"));
          });

          calendar.fullCalendar('unselect');
        };
      },

      eventDrop: function(event, delta, revertFunc) {
        event_data = { 
          event: {
            id: event.id,
            start: event.start.format(),
            end: event.end.format()
          }
        };
        $.ajax({
            url: event.update_url,
            data: event_data,
            type: 'PATCH'
        });
      },
      
      eventClick: function(event, jsEvent, view) {
        $.getScript(event.edit_url, function() {
          $('#event_date_range').val(moment(event.start).format("MM/DD/YYYY HH:mm") + ' - ' + moment(event.end).format("MM/DD/YYYY HH:mm"))
          //date_range_picker();
          $('.start_hidden').val(moment(event.start).format('YYYY-MM-DD HH:mm'));
          $('.end_hidden').val(moment(event.end).format('YYYY-MM-DD HH:mm'));
        });
      },
      
      eventAfterRender: function(event, element, view) {
        if (view.name !== 'month') {
          //$(element).css('width','25%'); // Narrower width unless it's calendar view
          // view consist Available views:
          // month, basicWeek,basicDay,agendaWeek,agendaDay
        }
      }
      
    });
  })
};
$(document).on('turbolinks:load', initialize_calendar);