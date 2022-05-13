module ThemeProvider exposing
    ( fromList, Theme
    , globalProvider
    , provider
    , DarkModeStrategy(..)
    , globalProviderWithDarkMode, providerWithDarkMode
    )

{-|


# Creating a Theme

Before using a **Theme** you need to create one! Thankfully it is really easy to do so:

@docs fromList, Theme


# Propagating Themes

After creating one or more themes, you can use them in a few different ways.

@docs globalProvider

Now… **say you have a marketing website and each section of your website can use one of a number of available themes**. It would be really useful to create things using CSS variables and then just apply the theme you want when you want, right?

@docs provider


# Themes and Dark Mode

You can also use two similar functions as the ones above for specifying themes that automatically switch to a dark mode based on a defined strategy. The first thing to do then is decide which dark mode strategy will be the right one for your use case:

@docs DarkModeStrategy

@docs globalProviderWithDarkMode, providerWithDarkMode

-}

import Html as H
import Html.Attributes as HA
import Internal.Hash



-- Creating Themes


{-| -}
type Theme
    = Theme { namespace : String, styles : String }


{-| Creates a theme based on a namespace and a list of CSS variables names and their values.

    lightTheme : Theme
    lightTheme =
        Theme.fromList "my-theme"
            [ ( "background", "white"
            , ( "base", "black" )
            , ( "accent", "blue" )
            ]

**A Theme is just a set of scoped CSS variables** so the namespace attribute can be used to avoid name-clashing with other variables already in scope.

-}
fromList : String -> List ( String, String ) -> Theme
fromList namespace_ list =
    list
        |> List.map (\( k, v ) -> "--" ++ namespace_ ++ "-" ++ k ++ ":" ++ v)
        |> String.join ";"
        |> (\styles_ ->
                Theme
                    { namespace = namespace_
                    , styles = styles_
                    }
           )


namespace : Theme -> String
namespace (Theme theme) =
    theme.namespace


styles : Theme -> String
styles (Theme theme) =
    theme.styles


{-| Used to propagate themes to an specific scope.

    main : Html msg
    main =
        div []
            [ ThemeProvider.globalProvider defaultTheme

            -- section using the default theme
            , section [] [ .. ]

            -- section using the orange theme
            , ThemeProvider.provider orangeTheme [] [ .. ]
            ]

-}
provider :
    Theme
    -> List (H.Attribute msg)
    -> List (H.Html msg)
    -> H.Html msg
provider theme =
    provider_
        { light = theme
        , dark = Nothing
        , strategy = SystemStrategy
        }


{-| Used to provide a **Theme** globally. It will be applied to your `body` element and it will be available for use anywhere in your application.

    main : Html msg
    main =
        div []
            [ ThemeProvider.globalProvider lightTheme
            , p [ style "color" "var(--my-theme-accent)" ]
                [ text "I have the `accent` color" ]
            ]

**Note**: You are still able to overwrite this **Theme** locally.

-}
globalProvider : Theme -> H.Html msg
globalProvider theme =
    globalProvider_
        { light = theme
        , dark = Nothing
        , strategy = SystemStrategy
        }


{-| Defines the dark mode strategy.

  - `SystemStrategy` uses the user system settings.
  - `ClassStrategy` uses the presence of a CSS class to determine dark mode.

-}
type DarkModeStrategy
    = SystemStrategy
    | ClassStrategy String


{-| Used to provide a Theme globally with a dark mode alternative. Themes will automatically switch based on the strategy condition.

    main : Html msg
    main =
        div []
            [ ThemeProvider.globalProviderWithDarkMode
                { light = lightTheme
                , dark = darkTheme
                , strategy = ThemeProvider.SystemStrategy
                }
            , p [ style "color" "var(--my-theme-accent)" ]
                [ text "I have the `accent` color" ]
            ]

**Note**: You are still able to overwrite this **Theme** locally.

-}
globalProviderWithDarkMode : { light : Theme, dark : Theme, strategy : DarkModeStrategy } -> H.Html msg
globalProviderWithDarkMode props =
    globalProvider_
        { light = props.light
        , dark = Just props.dark
        , strategy = props.strategy
        }


{-| Used to propagate themes to an specific scope with a dark mode alternative. Themes will automatically switch based on the strategy condition.

    main : Html msg
    main =
        div []
            [ ThemeProvider.globalProviderWithDarkMode
                { light = lightTheme
                , dark = darkTheme
                , strategy = ThemeProvider.SystemStrategy
                }

            -- section using the default light or dark theme
            , section [] [ .. ]

            -- section using the orange light and dark themes
            , ThemeProvider.providerWithDarkMode
                { light = lightOrange
                , dark = darkOrange
                , strategy = ThemeProvider.SystemStrategy
                }
                [] [ .. ]
            ]

-}
providerWithDarkMode :
    { light : Theme, dark : Theme, strategy : DarkModeStrategy }
    -> List (H.Attribute msg)
    -> List (H.Html msg)
    -> H.Html msg
providerWithDarkMode props =
    provider_
        { light = props.light
        , dark = Just props.dark
        , strategy = props.strategy
        }



-- Hash


hashString : String -> Int
hashString =
    Internal.Hash.hashString 0



-- Default


globalProvider_ :
    { light : Theme
    , dark : Maybe Theme
    , strategy : DarkModeStrategy
    }
    -> H.Html msg
globalProvider_ props =
    H.div []
        [ H.node "style"
            []
            [ H.text ("body { " ++ styles props.light ++ " }") ]
        , case props.dark of
            Just dark ->
                case props.strategy of
                    ClassStrategy darkClass ->
                        H.node "style"
                            []
                            [ H.text ("." ++ darkClass ++ " { " ++ styles dark ++ "; color-scheme: dark; }") ]

                    SystemStrategy ->
                        H.node "style"
                            []
                            [ H.text ("@media (prefers-color-scheme: dark) { body { " ++ styles dark ++ "; color-scheme: dark; } }") ]

            Nothing ->
                H.text ""
        ]


provider_ :
    { light : Theme
    , dark : Maybe Theme
    , strategy : DarkModeStrategy
    }
    -> List (H.Attribute msg)
    -> List (H.Html msg)
    -> H.Html msg
provider_ props attrs children =
    case props.dark of
        Just dark ->
            let
                targetClass =
                    dark
                        |> styles
                        |> hashString
                        |> (\hash -> namespace dark ++ "-" ++ String.fromInt hash)
            in
            case props.strategy of
                ClassStrategy darkClass ->
                    H.div
                        (HA.class targetClass :: attrs)
                        (H.node
                            "style"
                            []
                            [ H.text ("." ++ targetClass ++ " { " ++ styles props.light ++ " } ." ++ darkClass ++ " ." ++ targetClass ++ " { " ++ styles dark ++ "; color-scheme: dark; }") ]
                            :: children
                        )

                SystemStrategy ->
                    H.div
                        (HA.class targetClass :: attrs)
                        (H.node
                            "style"
                            []
                            [ H.text ("." ++ targetClass ++ " { " ++ styles props.light ++ " } @media (prefers-color-scheme: dark) { ." ++ targetClass ++ " { " ++ styles dark ++ "; color-scheme: dark; } }") ]
                            :: children
                        )

        Nothing ->
            H.div (HA.attribute "style" (styles props.light) :: attrs) children
