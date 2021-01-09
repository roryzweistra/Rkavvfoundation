
$( document ).on( 'click', '.navbar-burger', function( e ) {
    var $self   = $( this );

    if ( $self.hasClass( 'is-active' ) ) {
        $( '.navbar-menu' ).removeClass( 'is-active' );
        $self.removeClass( 'is-active' );
    }
    else {
        $self.addClass( 'is-active' );
        $( '.navbar-menu' ).addClass( 'is-active' );
    }

});
