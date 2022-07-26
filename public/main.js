// Initial data passed to Elm (should match `Flags` defined in `Shared.elm`)
// https://guide.elm-lang.org/interop/flags.html
var flags = {width: screen.width, height: screen.height}

// Start our Elm application
var app = Elm.Main.init({ flags: flags })

// Ports