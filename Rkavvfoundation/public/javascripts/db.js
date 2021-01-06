
// $( document ).on( 'click', '.db-search-holiday-button', function( e ) {
//     e.preventDefault();
//
//     $.ajax({
//         dataType    : 'html',
//         type        : 'POST',
//         data        : {
//             'destination'  : $( '.db-search-holiday-destination' ).val()
//         },
//         url         : '/search/',
//         success     : function( data ) {
//
//         }
//     });
//
// });

var get_lowest = function( e ) {

    $( '.js-db-calender-price-column' ).each( function( e ) {
        var $self       = $( this );
        var first       = 0;
        var lowest      = 0;
        var id          = 0;
        var start_date  = 0;
        var night       = 0;
        var airport     = '';
        var board       = '';

        $self.find( '.js-db-calender-price' ).not( '.is-hidden' ).each( function( e ) {
            var $self_price = $( this );
            $self_price.addClass( 'is-hidden' );

            if ( first === 0 ) {
                lowest      = $self_price.attr( 'data-price'        );
                id          = $self_price.attr( 'data-id'           );
                start_date  = $self_price.attr( 'data-startdate'    );
                night       = $self_price.attr( 'data-night'        );
                airport     = $self_price.attr( 'data-airport'      ).toLowerCase();
                board       = $self_price.attr( 'data-board'        ).toLowerCase();
                first       = 1;
            }
            //$( this ).addClass( 'is-hidden' );
            if ( lowest > $self_price.attr( 'data-price'  ) ) {
                lowest      = $self_price.attr( 'data-price'        );
                id          = $self_price.attr( 'data-id'           );
                start_date  = $self_price.attr( 'data-startdate'    );
                night       = $self_price.attr( 'data-night'        );
                airport     = $self_price.attr( 'data-airport'      ).toLowerCase();
                board       = $self_price.attr( 'data-board'        ).toLowerCase();
            }

        });

        var class_match = '.js-db-calender-id-' + id + '.js-db-price-night-' + night + '.js-db-price-board-'
            + board + '.js-db-price-airport-' + airport + '.js-db-price-startdate-' + start_date
        ;

        $( class_match ).removeClass( 'is-hidden' );

    });

};


$( document ).on( 'change', '.js-db-calender-form-board', function( e ) {
    var $self   = $( this );
    var airport = $( '.js-db-calender-form-airport' ).children( 'option:selected' ).val().toLowerCase();
    var board   = $( '.js-db-calender-form-board'   ).children( 'option:selected' ).val().toLowerCase();
    $( '.js-db-calender-price' ).addClass( 'is-hidden' );
    $( '.js-db-calender-price' ).each( function( e ) {

        if ( $( this ).hasClass( 'js-db-price-airport-' + airport ) && $( this ).hasClass( 'js-db-price-board-' + board  ) ) {
            $( this ).removeClass( 'is-hidden' );
        }

    });

    get_lowest();
});

$( document ).on( 'change', '.js-db-calender-form-airport', function( e ) {
    var $self   = $( this );
    var airport = $( '.js-db-calender-form-airport' ).children( 'option:selected' ).val();
    var board   = $( '.js-db-calender-form-board'   ).children( 'option:selected' ).val();
    $( '.js-db-calender-price' ).addClass( 'is-hidden' );
    $( '.js-db-calender-price' ).each( function( e ) {

        if ( $( this ).hasClass( 'js-db-price-airport-' + airport ) && $( this ).hasClass( 'js-db-price-board-' + board  ) ) {
            $( this ).removeClass( 'is-hidden' );
        }

    });

    get_lowest();
});

$( document ).on( 'click', '.js-db-get-holiday', function( e ) {
    e.preventDefault();
    var $self = $( this );

    $( '.db-price-calculator-placeholder' ).html( '<h2>Een ogenblik geduld. De actuele prijs informatie wordt opgehaald</h2>' );

    $.ajax({
        dataType    : 'html',
        type        : 'POST',
        data        : {
            'accommodation_id'  : $( this ).attr( 'data-accommodation-id'   ),
            'arrival_airport'   : $( this ).attr( 'data-arrival-airport'    ),
            'board_type'        : $( this ).attr( 'data-board-type'         ),
            'departure_airport' : $( this ).attr( 'data-departure-airport'  ),
            'night_count'       : $( this ).attr( 'data-night-count'        ),
            'start_date'        : $( this ).attr( 'data-start-date'         ),
            'transport_type'    : $( this ).attr( 'data-transport-type'     ),
            'transport_code'    : $( this ).attr( 'data-transport-code'     )
        },
        url         : '/book/get-bookable-units',
        success     : function( data ) {
            $( '.db-price-calculator-placeholder' ).html( data );
        }
    });

});
