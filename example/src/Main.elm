module Main exposing (main)

import ElmBook exposing (Book, book, withChapters)
import ElmBook.Chapter exposing (chapter, renderComponentList)
import Html as H
import Html.Attributes as HA
import ThemeProvider


lightTheme : ThemeProvider.Theme
lightTheme =
    ThemeProvider.fromList
        [ ( "color", "blue" )
        , ( "bg", "aliceblue" )
        ]


darkTheme : ThemeProvider.Theme
darkTheme =
    ThemeProvider.fromList
        [ ( "color", "aliceblue" )
        , ( "bg", "blue" )
        ]


optimized : ThemeProvider.OptimizedTheme msg
optimized =
    ThemeProvider.optimizedTheme lightTheme


optimizedWithDarkMode : ThemeProvider.OptimizedTheme msg
optimizedWithDarkMode =
    ThemeProvider.optimizedThemeWithDarkMode
        { light = darkTheme
        , dark = lightTheme
        , strategy = ThemeProvider.ClassStrategy "elm-book-dark-mode"
        }


sample : H.Html msg
sample =
    H.p
        [ HA.style "color" "var(--color)"
        , HA.style "background" "var(--bg)"
        , HA.style "padding" "20px"
        , HA.style "margin" "0"
        ]
        [ H.text "Text" ]


main : Book ()
main =
    book "ThemeProvider"
        |> withChapters
            [ chapter "Guide"
                |> renderComponentList
                    [ ( "Global provider"
                      , H.div
                            []
                            [ ThemeProvider.globalProvider lightTheme
                            , sample
                            , ThemeProvider.provider darkTheme
                                []
                                [ sample ]
                            ]
                      )
                    ]
            , chapter "System Strategy"
                |> renderComponentList
                    [ ( "Dark Mode (System)"
                      , H.div
                            []
                            [ ThemeProvider.globalProviderWithDarkMode
                                { light = lightTheme
                                , dark = darkTheme
                                , strategy = ThemeProvider.SystemStrategy
                                }
                            , sample
                            , ThemeProvider.providerWithDarkMode
                                { light = darkTheme
                                , dark = lightTheme
                                , strategy = ThemeProvider.SystemStrategy
                                }
                                []
                                [ sample ]
                            ]
                      )
                    ]
            , chapter "Class Strategy"
                |> renderComponentList
                    [ ( "Dark Mode (Class)"
                      , H.div
                            []
                            [ ThemeProvider.globalProviderWithDarkMode
                                { light = lightTheme
                                , dark = darkTheme
                                , strategy = ThemeProvider.ClassStrategy "elm-book-dark-mode"
                                }
                            , sample
                            , ThemeProvider.providerWithDarkMode
                                { light = darkTheme
                                , dark = lightTheme
                                , strategy = ThemeProvider.ClassStrategy "elm-book-dark-mode"
                                }
                                []
                                [ sample ]
                            ]
                      )
                    ]
            , chapter "Optimized"
                |> renderComponentList
                    [ ( "Optimized"
                      , H.div
                            []
                            [ optimized.styles
                            , optimizedWithDarkMode.styles
                            , optimized.provider
                                []
                                [ sample ]
                            , optimizedWithDarkMode.provider
                                []
                                [ sample ]
                            ]
                      )
                    ]
            ]
