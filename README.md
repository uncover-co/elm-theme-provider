# elm-theme-provider

This package is used for creating "themes" based on CSS variables and propagating them through your application. It also provides strategies to deal with dark mode easily.

You can pick one of the themes from [elm-theme-spec](https://package.elm-lang.org/packages/uncover-co/elm-theme-spec/latest/) or you can define your own like so:

```elm
    lightTheme : Theme
    lightTheme =
        Theme.fromList "my-theme"
            [ ( "background", "white"
            , ( "accent", "blue" )
            ]


    darkTheme : Theme
    darkTheme =
        Theme.fromList "my-theme"
            [ ( "background", "black"
            , ( "accent", "blue" )
            ]


    main : Html msg
    main =
        div []
            [ -- provide both light and dark themes globally
              -- SystemStrategy will use the user's system settings
              ThemeProvider.globalProviderWithDarkMode
                { light = lightTheme
                , dark = darkTheme
                , strategy = ThemeProvider.SystemStrategy
                }

            -- section using the default light or dark theme
            , section [] [ .. ]

            -- section using an scoped theme
            , ThemeProvider.provider specialTheme [] [ .. ]
            ]
```
